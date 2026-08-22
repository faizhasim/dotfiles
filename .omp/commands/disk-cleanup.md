---
description: "Analyze disk usage, rank cleanup candidates by gain vs value vs safety, then free space — every action confirmed via ask."
---

# Disk Cleanup

Goal: reclaim disk space reliably. Analyze first, propose a ranked plan (gain vs value vs safety), get explicit approval via `ask`, execute only approved items, report what was actually freed.

## Step 0 — Hard rules

- **Never delete anything without an explicit `ask` approval for that exact item.** The `ask` tool is the only approval path. Batch all proposals into ONE `ask` call (multiple questions in a single call). No auto-cleanup and no "clean everything" shortcut unless the user picks that option.
- Read-only analysis first: measure, then propose. Never clean during the inventory step.
- Prefer each tool's native clean/prune command over `rm -rf`. `rm -rf` is allowed only for cache directories named in the Step 2 inventory, and only after approval.
- Never run `docker system prune --volumes` unless the user explicitly picks the volumes-inclusive option — volumes are persistent data, not cache.
- Nix store GC needs sudo and removes old generations (rollback history). Always show the dry-run result before asking.
- Record `df -h /` before and after; report actual reclaimed space.

## Step 1 — Baseline

Run `df -h /` and note used/free. All proposals are sized relative to this baseline at invocation time — sizes drift, so re-measure in Step 2.

## Step 2 — Inventory (re-measure)

Measure each candidate with `dust` — `dust -d 0 <path>` prints only that path's total (root row), and you can batch several paths in one call (`dust -d 0 <path1> <path2> …`) to get all totals at once. Skip any path that doesn't exist or measures under 100 MB. Do not run full-disk scans. If `dust` is not installed (`command -v dust`), fall back to `du -sh`.

| Candidate                                                                                                                                                                           | Measure command                               | Cleanup command                                                                                     | Dry-run available                              | Risk                                                       |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------- |
| uv cache (`~/.cache/uv`)                                                                                                                                                            | `dust -d 0 ~/.cache/uv`                       | `uv cache clean`                                                                                    | none                                           | safe — wheels re-download                                  |
| Docker Desktop VM (`~/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw`)                                                                                             | `dust -d 0 <Docker.raw path>`                 | start Docker → `docker system prune -af` → shrink image in Settings; or quit Docker + delete `.raw` | `docker system df`                             | destructive — deleting `.raw` wipes all images AND volumes |
| Nix store (`/nix/store`)                                                                                                                                                            | `dust -d 0 /nix/store`                        | `nh clean all -k 1 -K 30d --optimise -e auto` (fallback: `sudo nix-collect-garbage -d`)             | `nh clean all -n` or `nix store gc --dry-run`  | care — sudo; removes old generations                       |
| mise tools (`~/.local/share/mise`)                                                                                                                                                  | `dust -d 0 ~/.local/share/mise`               | `mise prune`                                                                                        | `mise prune --dry-run`                         | safe — unused versions, reinstall on demand                |
| pnpm store (`pnpm store path`)                                                                                                                                                      | `dust -d 0 "$(pnpm store path)"`              | `pnpm store prune`                                                                                  | none                                           | safe                                                       |
| npm cache (`~/.npm`)                                                                                                                                                                | `dust -d 0 ~/.npm`                            | `npm cache clean --force`                                                                           | `npm cache verify`                             | safe                                                       |
| Homebrew cache (`$(brew --cache)`)                                                                                                                                                  | `dust -d 0 "$(brew --cache)"`                 | `brew cleanup` + `brew autoremove`                                                                  | `brew cleanup -n`, `brew autoremove --dry-run` | safe                                                       |
| App caches: `~/Library/Caches/{Microsoft Edge,JetBrains,puccinialin,aws,pnpm,pip}`, `~/.cache/{puppeteer,qmd,nix}`, Slack cache subdirs under `~/Library/Application Support/Slack` | `dust -d 0 <each cache path>`                 | quit the app if running; `rm -rf <path>` (or `pip cache purge` for pip)                             | none                                           | safe — regenerates                                         |
| Rust toolchains (`~/.rustup`)                                                                                                                                                       | `dust -d 0 ~/.rustup`                         | `rustup toolchain uninstall <inactive-nightly>` (keep the active stable)                            | `rustup toolchain list`                        | one-off                                                    |
| Simulators (`~/Library/Developer/CoreSimulator`)                                                                                                                                    | `dust -d 0 ~/Library/Developer/CoreSimulator` | `xcrun simctl delete unavailable`; `xcrun simctl runtime delete --all` only if approved             | `xcrun simctl list`                            | care — removes devices/runtimes                            |
| Logs (`~/Library/Logs`)                                                                                                                                                             | `dust -d 1 -n 5 ~/Library/Logs`               | remove stale app logs                                                                               | none                                           | safe                                                       |
| Trash (`~/.Trash`)                                                                                                                                                                  | `dust -d 0 ~/.Trash`                          | `rm -rf ~/.Trash/*`                                                                                 | none                                           | safe                                                       |

`nh` reliability check: `command -v nh`. If present, prefer `nh clean all` (it keeps the current generation; `-k 1 -K 30d` aligns with the flake's `nix.gc.options = "--delete-older-than 30d"`, and `--optimise` dedupes the store afterwards). `nh clean all -n` is the dry-run. If `nh` is absent, fall back to `nix-collect-garbage`.

## Step 3 — Evaluate gains vs value vs safety

Score every measured candidate on three axes:

- **Gain** — size in GB.
- **Value** — recurring (cache refills; clean often: uv, npm, pnpm, browser/app caches) vs one-off (dead nix paths, inactive rustup nightly).
- **Safety** — safe (cache, regenerates) / care (sudo, app must quit, or removes runtimes) / destructive (persistent data: Docker volumes).

Classify into tiers:

- **Tier A — safe, recurring caches** (highest value per effort): uv, npm, pnpm store, pip, puppeteer, qmd, Edge, JetBrains, Slack, puccinialin, aws, nix binary cache (`~/.cache/nix`), Homebrew cache.
- **Tier B — care needed**: Nix store GC (sudo; keeps current generation + recent history), mise prune (dry-run first), CoreSimulator (unavailable devices only unless user opts for all), inactive rustup nightly (one-off), Docker prune (daemon must be started; volumes variant destructive).
- **Tier C — dotfiles config** (recurring savings with no manual cleanup):
  - `nix.settings.auto-optimise-store = true` — dedupes identical store paths at every build.
  - `nix.optimise.automatic = true` + `nix.optimise.dates = [ "03:45" ]` — scheduled `nix store optimise`.
  - `homebrew.onActivation.cleanup = "uninstall"` in `darwin/homebrew/default.nix` (currently `"none"`) — runs `brew cleanup` on every rebuild.
  - Already configured, keep as-is: `nix.gc.automatic = true`, weekly, `--delete-older-than 30d` (in `flake.nix`).

Merge anything under 500 MB into one "misc small caches" option rather than prompting per item.

## Step 4 — Propose with ask

Present the ranked table (item, size, safety tier, exact command) in the message, then ONE `ask` call covering every proposal. Put size and risk in each question's text. Example question set (build options from the Step 2 measurements; drop zero-size paths):

1. `Caches to clean` — `multi: true`; one option per Tier A cache with its size, plus `misc small caches`. Recommended: the largest cache. Selecting nothing = skip all.
2. `Nix store GC` — options: `GC keeping 1 generation + 30d history (dry-run shown first)` (recommended), `GC + delete ALL old generations (-d)`, `skip`.
3. `Docker` — options: `start Docker and prune unused images + build cache`, `prune INCLUDING volumes (destructive — persistent data)`, `skip` (recommended if the daemon is down and the user is unlikely to want it started).
4. `mise prune` — options: `prune unused tool versions (dry-run first)` (recommended), `skip`.
5. `Rust nightly` — options: `uninstall inactive nightly (<size>)` (recommended if > 500 MB), `skip`.
6. `Simulators` — options: `delete unavailable devices only`, `delete ALL simulators/runtimes`, `skip` (recommended).
7. `Dotfiles config` — options: `auto-optimise-store + scheduled optimise`, `homebrew cleanup "uninstall"`, `both`, `skip`.

Do not execute anything before the `ask` returns. If the user cancels, stop and report.

## Step 5 — Execute approved items only

Order:

1. Dry-run everything that supports it and show the previews: `nh clean all -n`, `nix store gc --dry-run`, `brew cleanup -n`, `brew autoremove --dry-run`, `mise prune --dry-run`, `docker system df`.
2. Tier A caches: use native CLIs (`uv cache clean`, `npm cache clean --force`, `pnpm store prune`, `pip cache purge`, `brew cleanup`, `brew autoremove`, `mise prune`). For `rm -rf` targets, verify the basename is in the Step 2 inventory before removing and quit the owning app first (Edge, JetBrains, Slack).
3. Nix store GC: if `nh` is available, `nh clean all -k 1 -K 30d --optimise -e auto` (auto-elevates via sudo; align flags with the flake's GC config). Otherwise `sudo nix-collect-garbage -d`. Confirm the sudo password prompt with the user if running non-interactively.
4. Docker (only if approved): `open -a Docker`, wait for `docker info` to succeed, run `docker system prune -af` (+ `--volumes` only if that option was chosen), then offer shrinking the VM image (Docker Desktop → Settings → Resources → Disk image) and show `docker system df` before/after.
5. Simulators: `xcrun simctl delete unavailable`; `xcrun simctl runtime delete --all` only if explicitly approved.
6. Rust: `rustup toolchain uninstall <nightly>` — keep the active stable toolchain.
7. Tier C config (only if approved): edit `flake.nix` for `auto-optimise-store` / `optimise.automatic`, and `darwin/homebrew/default.nix` for `cleanup = "uninstall"`. Do not run a rebuild from this command — remind the user instead.

## Step 6 — Report

- Show `df -h /` before vs after and the per-item freed space where measurable.
- Summary table: item → approved → freed → skipped.
- Note anything that regenerates (caches) so the user isn't surprised.
- If dotfiles config changed, restate the rebuild command: `nix flake check` and `darwin-rebuild switch --flake .#<host>` (host from `scutil --get ComputerName`).
