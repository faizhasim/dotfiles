---
description: "Diff the live OMP config against the repo-tracked baseline template and selectively promote, revert, or leave each drifted setting."
---

# Config Diff

Compare the mutable, machine-local `~/.omp/agent/config.yml` against the repo-tracked baseline template it was seeded from, and reconcile any drift key-by-key.

## Step 1 — Paths

| File                     | Path                                                                                                                                                                                       | Role                                                                                                         |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| Template (repo baseline) | `home-manager/oh-my-pi/config.yml` (relative to the repo root, `${HOME}/dev/faizhasim/dotfiles`)                                                                                           | Git-tracked, hand-maintained. New machines are seeded from this.                                             |
| Live config              | `~/.omp/agent/config.yml`                                                                                                                                                                  | Mutable. Written by `/settings` and other in-session omp writes. Never touched by Nix after initial seeding. |
| `modelRoles` (excluded)  | Patched directly into `~/.omp/agent/config.yml` on every `darwin-rebuild switch` via `yq eval -i`, sourced from `models.omp` / `model-profiles.nix`. Not part of the template file at all. | Excluded from this diff entirely; re-synced every rebuild regardless of drift (see note below).              |

`modelRoles` is **never** part of this diff. It's re-synced in place on every rebuild regardless of any other local drift, so it will always be present and "current" in the live file — that's expected, not drift, and never actionable. Verify the effective value with `omp config get modelRoles --json` if you need to confirm what's actually loaded, rather than trusting a stale read of the file.

If `~/.omp/agent/config.yml` does not exist, stop here and tell the user: the machine hasn't run omp yet (or the live file was never seeded), so there's nothing to diff. Don't fabricate a diff against an empty file.

## Step 1.5 — Cross-check against the current schema

The template is hand-maintained and can go stale relative to the omp version actually running (renamed keys, removed keys, boolean settings migrated to enums). Before classifying anything as drift, ground both files against the installed omp's own schema:

1. Run `omp config list --json` once. This returns every known key with its **effective** value for the current install — i.e. built-in default overridden by whatever `~/.omp/agent/config.yml` already contains. Because it reads the live file, a live-only key's value in this dump will trivially equal the live file's value; it does **not** tell you whether that value is a deliberate customization or just an untouched default. Use this dump only to check whether a key **exists at all** in the current schema.
2. To get true factory defaults (independent of the live file), use a fresh, never-before-used throwaway profile name (lowercase alphanumeric, e.g. `tmpdiffprobe`). First confirm isolation — don't assume it: run `omp --profile <throwaway-name> config path --json` and check the reported path is **not** `~/.omp/agent/config.yml` (it resolves to a separate directory, e.g. `~/.omp/profiles/<throwaway-name>/agent`). Only once that's confirmed, run `omp --profile <throwaway-name> config list --json` — a brand-new profile has no config file yet, so every value returned is the real built-in default. If the reported path ever matches the live file, stop and fall back to reading `docs/` / schema source for defaults instead — never probe against the real `~/.omp/agent/config.yml`.
3. For every template-only key, look it up in the schema dump:
   - **Missing from the schema entirely** → the setting was removed outright (no successor). Recommend deleting it from the template; there is nothing to promote/revert/keep for a dead key.
   - **Present in the schema, and a live-only key covers the same concern under a new name or shape** (e.g. a boolean `foo.enabled` replaced by an enum `foo.mode`, or a singular setting replaced by an ordered list) → this is a **rename**, not independent live-only + template-only drift. Pair them and present as one migration decision (see Step 3), even though the flatten step reports them as two separate keys.
4. For every live-only key, compare its value against the true factory default from step 2:
   - **Equal to the factory default** → this is schema noise: a key that only exists because the installed omp version is newer than the template, not evidence the user customized anything. Don't prompt on it individually — tally it in a "new schema keys, still at default" note instead (Step 3).
   - **Different from the factory default** → genuine local customization. This is real drift and needs a decision.
5. A key whose type changed (e.g. template has a bare boolean for a setting the schema dump now lists as `type: enum`) is stale/invalid under the current schema regardless of any live preference — the template must be updated to a valid value either way. To discover an enum's valid choices, never probe against the real `~/.omp/agent/config.yml`: an unlucky guess that happens to be valid would silently mutate the live file. Instead probe against the same throwaway `--profile` from step 2 (e.g. `omp --profile <throwaway-name> config set <key> bogus`) — its rejection error lists the valid values, and any isolated profile state is disposable. Still ask the user which valid value to adopt; don't silently pick one.

## Step 2 — Normalize and diff

Read both files in full:

- `home-manager/oh-my-pi/config.yml`
- `~/.omp/agent/config.yml`

Parse both as YAML and compare **structurally**, section by section and key by key — not a raw line/text diff. The live file's key order commonly differs from the template after omp rewrites it, so line-based diffing would report false drift on reordering alone.

Strip `modelRoles` out of the live file's parsed structure before comparing (per Step 1 — it's Nix-patched on every rebuild, never part of the drift set).

For every remaining top-level key and nested section, classify it as one of:

1. **Unchanged** — same value in both files. Skip; don't mention it.
2. **Drifted** — present in both, but values differ (a scalar changed, a list gained/lost entries, a nested block was edited).
3. **Live-only** — key exists in the live file but not the template. Per Step 1.5, split this into two sub-cases: schema noise (value equals the true factory default — a newer omp version simply materialized the key) versus a genuine customization (value differs from the factory default).
4. **Template-only** — key exists in the template but not the live file. Per Step 1.5, split this into: renamed (a live-only key covers the same setting under its current name/shape — pair them) versus genuinely removed (missing from the current schema entirely, no successor).

Build a flat list of drifted items with: key path, template value, live value.

## Step 3 — Present and prompt

Group related keys before prompting:

- Keys that are one rename pair (Step 1.5.3) — present the old template key and its new live-side name/value together as a single migration decision, not two independent items.
- Keys that clearly belong to one settings block edited together (e.g. a whole `agent:` sub-block, or keys clearly touched in the same `/settings` session) — one batched diff, one ask.
- Otherwise, unrelated keys get their own question — but batch every question for this run into one `ask` call with multiple entries, so the user resolves the whole diff in a single prompt instead of one round-trip per item.

For each drifted item, rename pair, or batch, show the template value vs. the live value, then offer these options:

- `promote` — copy the live value into the repo template; this becomes the new baseline for future machines. For a rename pair, this means replacing the old template key with the new key/value.
- `keep-local` — leave both files as-is; acknowledged, no file changes.
- `revert` — overwrite the live value back to the template's value. For a live-only key with no template baseline (no rename pair), there is nothing to revert _to_ — treat `revert` as "reset to the schema's true factory default" instead (see Step 4).

Handle the two Step 1.5 sub-cases outside the main prompt:

- **Live-only, matches factory default (schema noise)** — don't ask per key. Roll these into one informational line in the summary ("N new schema keys present at their default, no action needed") and move on.
- **Template-only, genuinely removed from the schema** — don't offer promote/revert (there's no live counterpart and no valid value to set). Ask once, batched, whether to delete these dead keys from the template.

## Step 4 — Execute

For each decision made in Step 3:

| Decision     | Action                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `promote`    | Edit `home-manager/oh-my-pi/config.yml`, setting that key to the live file's value.                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `keep-local` | No file edit. Just tally it for the summary.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `revert`     | Run `omp config set <key> <template-value>` (per `omp config` CLI) so the write goes through OMP's own schema validation rather than a raw file edit; falls back to editing `~/.omp/agent/config.yml` directly only if `omp config set` rejects the key (e.g. it isn't a scalar/leaf setting). For a live-only key with no template baseline, `<template-value>` is the schema's true factory default from the Step 1.5 throwaway-profile probe; prefer `omp config reset <key>` if the CLI supports `reset` for that key. |

When editing `home-manager/oh-my-pi/config.yml`, preserve existing YAML comments, key ordering, and formatting elsewhere in the file — touch only the lines belonging to the promoted key(s). Use the `edit` tool for surgical changes rather than rewriting the whole file.

When falling back to a direct edit of `~/.omp/agent/config.yml` for a `revert`, the same care isn't required (it's a machine-local, omp-managed file), but still only touch the reverted key(s).

For a rename pair resolved as `promote`: remove the old key from the template and add the new key/value in its place — never leave both the dead and current key in the template. For genuinely-removed dead keys the user approved deleting (Step 3): delete those lines from the template outright. `keep-local`/`revert` don't apply to dead keys — there's no live counterpart to promote from and no factory default to revert to, so the only choices are delete or leave as-is.

## Step 5 — Summary

Report final counts: `X promoted, Y kept local, Z reverted`.

If anything was promoted, remind the user:

1. `git add home-manager/oh-my-pi/config.yml`
2. Commit the change, since the template is the new baseline other machines will seed from.

If `modelRoles` was seen in the live file (Step 1), restate that it's Nix-patched on every rebuild and was left untouched — no overlay, no precedence layering, just a direct in-place sync.
