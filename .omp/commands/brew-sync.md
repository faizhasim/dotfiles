---
description: "Sync Homebrew inventory against Nix config — diff installed apps vs declared Brewfile, manage keep-list for MDM/manual apps."
---

# Brew Sync

Audit what's installed via Homebrew against the Nix-declared Brewfile and your intentional keep-list.

## Step 1 — Detect host and paths

Determine the hostname to pick the right machine-specific config:

```bash
HOST=$(scutil --get ComputerName 2>/dev/null)
echo "Host: $HOST"
```

Paths:
- Common config: `darwin/homebrew/common.nix`
- M3419 config: `darwin/homebrew/M3419.nix`
- macmini01 config: `darwin/homebrew/macmini01.nix`
- Keep-list: `.omp/tools/homebrew-keeps.json`

If `$HOST` is neither `M3419` nor `macmini01`, use common config only (no machine-specific).

## Step 2 — Scan installed apps

Run these and capture stdout:

| Source | Command |
|--------|---------|
| Formulae | `brew list --formula --quiet 2>/dev/null` |
| Casks | `brew list --cask --quiet 2>/dev/null` |
| MAS apps | `mas list 2>/dev/null` |
| Taps | `brew tap 2>/dev/null` |

## Step 3 — Read Nix configs

Read `darwin/homebrew/common.nix`, the host-specific config (if applicable), and `.omp/tools/homebrew-keeps.json`.

Parse each Nix file to extract the `brews`, `casks`, and `taps` lists. For taps that are expressed as attribute sets (`{ name = "..."; clone_target = "..."; ... }`), extract the `name`.

## Step 4 — Compute the diff

Build four lists:

1. **Missing from Nix** — installed but not declared in any Nix config or the keep-list
2. **Kept** — installed and in the keep-list (show for reference, no action needed)
3. **Declared but missing** — in Nix config but not installed (potential issue)
4. **In-sync** — declared and installed (hide from prompt unless user asks)

## Step 5 — Present and prompt

Show the user the **Missing from Nix** list first. For each item, use `ask` with these options:

- `keep` — add to keep-list (`.omp/tools/homebrew-keeps.json` under the right category: `brews`, `casks`, `mas`, or `taps`)
- `add:common` — add to `darwin/homebrew/common.nix` (shared across machines)
- `add:<HOST>` — add to `darwin/homebrew/<HOST>.nix` (machine-specific, e.g. `M3419.nix` or `macmini01.nix`)
- `remove` — uninstall via `brew uninstall` / `brew untap`
- `skip` — ignore for now (don't add to keep-list either)

If there are multiple items, batch them and ask once per category to avoid too many prompts.

Also show the **Declared but missing** list if non-empty (out-of-sync Nix declaration that hasn't been installed yet).

## Step 6 — Execute

For each action chosen:

| Action | What to do |
|--------|------------|
| `keep` | Append the item name to the appropriate array in `.omp/tools/homebrew-keeps.json`. Set `updated` to today's ISO date. |
| `add:common` | Append to the relevant list (`brews`, `casks`, or `taps`) in `darwin/homebrew/common.nix` |
| `add:M3419` | Append to the relevant list in `darwin/homebrew/M3419.nix` |
| `add:macmini01` | Append to the relevant list in `darwin/homebrew/macmini01.nix` |
| `remove` | Run `brew uninstall <name>` or `brew untap <name>` |

When adding to a Nix file, preserve the Nix formatting — insert the new entry as a string in the appropriate list, maintaining alphabetical order if possible.

If you add to a Nix config that has a `clone_target` tap definition, keep the existing attribute set and don't convert it to a plain string.

## Step 7 — Confirm and wrap up

After executing all actions:

1. Show a summary of what changed: `X kept, Y added to common, Z added to <HOST>, W removed`
2. If any Nix files were modified, tell the user to run `nix flake check` and `darwin-rebuild switch --flake .#<HOST>` to apply
3. If any apps were uninstalled, note it
