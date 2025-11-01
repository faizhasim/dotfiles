# Agents Guide

This is a **Nix/nix-darwin configuration repository** for declarative macOS system management.

## Build/Apply Commands
- **Initial build**: `sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#M3419` (or `#macmini01`, `#mbp01`)
- **After initial setup**: `darwin-rebuild switch --flake .#M3419`
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
