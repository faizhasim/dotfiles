# Agents Guide

This is a **Nix/nix-darwin configuration repository** for declarative macOS system management.

## Build/Apply Commands

- **Initial build**: `sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#M3419` (or `#macmini01`)
- **After initial setup**: `sudo HOMEBREW_GITHUB_API_TOKEN="$(op read op://personal/Github/token)" darwin-rebuild switch --flake .#M3419`
- **Check flake**: `nix flake check`
- **Update inputs**: `nix flake update`
- **Format Nix files**: `nix fmt`

## Code Style

- **Language**: Nix (declarative), shell scripts, TOML, Lua (Neovim)
- **Indentation**: 2 spaces (per `.editorconfig`)
- **Nix formatting**: Use `nixfmt` (configured as formatter in flake)
- **Nix conventions**: Use `inherit` for variable passing, `let...in` for local bindings
- **Imports**: Explicit parameter lists (e.g., `{ config, pkgs, lib, ... }:`), use `inherit` in `specialArgs`
- **File organization**: Modular - separate concerns (darwin/os/, home-manager/, overlays/)
- **Naming**: kebab-case for files (`my-config.nix`), camelCase for Nix attributes
- **Comments**: Explain "why" not "what", use `# comment` for single-line
- **Secrets**: NEVER commit secrets - use 1Password references (`op://vault/item/field`)
- **Machine-specific config**: Use `common.nix` + `{hostname}.nix` pattern for packages/homebrew

## Important Notes

- AeroSpace config uses raw TOML (not Nix-generated) due to formatting issues
- Neovim is managed via Stow/LazyVim (not Nix) for Mason compatibility and direct config access
- Three-layer package management: Nix (CLI tools), Homebrew (GUI apps), mise (runtime versions)

## Scripts

- **setup-post-nix.sh** - Post-Nix setup dispatcher. Targets: `pi`, `nvim`, `mcp`, `opencode`, `herdr`, `omp`, `skills`, `runner`, `misc`, `all`. Each target is a self-contained function.
- **edit-worktrunk-repos.sh** - Edit the encrypted `repos.toml` (decrypt → edit → re-encrypt via agenix).
- **wt-ensure-repo.sh** - Ensure a worktree exists for a given repo/PR.
- **clone-worktrunk-repos.sh** - Batch clone repos from `repos.toml`.

## Git Hooks

The pre-commit hook (`.githooks/pre-commit`, wired via `core.hooksPath`):

- **nixfmt** - Format staged `.nix` files and re-stage.
- **statix** - Lint staged `.nix` files.
- **shellcheck** - Lint staged `scripts/**/*.sh` files (zero-warnings standard).
- **markdownlint** - Lint staged `*.md` files.

## Dependency Automation

**Renovate only** (`.renovaterc.json5`). Dependabot removed.

- Weekly Saturday scans (Asia/Kuala_Lumpur).
- Per-input Nix PRs (separate, testable).
- `platformAutomerge: true` enabled; `auto-merge-deps.yml` workflow as fallback.
- Self-hosted `build-darwin` CI runs on all PRs (mac mini).

## Secrets

Managed with **agenix**:

- `secrets.nix` → `darwin/activation.nix` → `~/.config/worktrunk/repos.toml`
- Edit via `scripts/edit-worktrunk-repos.sh`
- Decryption key stored in 1Password (`op document get 'agenix-decryption-key'`)

## Terminal

- **Multiplexer**: Herdr (installed via mise, plugins via `setup-post-nix.sh herdr`).
- **Zellij**: Removed. No remaining references outside git history and `.github/instructions/memory.instruction.md`.

## Tools

- **nh** — Nicer `darwin-rebuild` wrapper with closure diff. `NH_FLAKE` env var configured in `home-manager/default.nix`.
- **mise** — Runtime version manager (node, go, python, rust, herdr).
