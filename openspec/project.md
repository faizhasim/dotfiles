# Project Context

## Purpose

A dotfiles to manage my machine setup and configurations, from personal to work machines. Currently focused on macOS, with no immediate plan to support Linux.
This is currently a personal project, but contributions are welcome. Since it's a public repository, please be mindful of not including any sensitive information in your configurations.

## Tech Stack

- nix
- home-manager
- shell scripts

## Project Conventions

### Code Style

[Describe your code style preferences, formatting rules, and naming conventions]

- Indentation: 2 spaces (see .editorconfig)
- Use camelCase for Nix attributes, kebab-case for filenames
- Prefer explicit parameter lists in Nix modules ({ config, pkgs, lib, ... }:)
- Use inherit for variable passing
- Comments: Explain "why" not "what"; use # for single-line comments
- All Nix code must pass nix-fmt for formatting
- Shell scripts should follow POSIX style and include a shebang (#!/bin/env bash)
- Lua configs (for Neovim) should use idiomatic Lua style

### Architecture Patterns

- Modular configuration: split into darwin/, home-manager/, overlays, and nvim/
- Machine-specific configs use {hostname}.nix pattern, shared configs in common.nix
- Home-manager manages user-level configs; nix-darwin manages system-level
- Overlays for custom packages and tweaks (overlays/)
- Use TOML for Aerospace config due to formatting issues with Nix-generated TOML
- Neovim config managed via Stow/LazyVim for Mason compatibility (not Nix)
- Layered package management: Nix for CLI tools, Homebrew for GUI apps, mise for runtime versions

### Testing Strategy

- Use nix flake check to validate flake integrity
- Use darwin-rebuild switch --dry-run before applying changes
- Test shell scripts manually or with simple test harnesses
- Validate overlays and custom packages with nix build
- For major changes, test on a non-critical machine first
- Ensure all configs can be rebuilt from scratch without manual intervention

### Git Workflow

- For external contributions, always use feature branches and PRs
- Use descriptive commit messages (what/why)

## Domain Context

- mac os configurations
- developer productivity tools

## Important Constraints

- No Linux support (macOS only)
- Do not commit secrets; use 1Password CLI references (op://vault/item/field)
- All configs must be reproducible and declarative
- Avoid hardcoding machine-specific values outside {hostname}.nix

## External Dependencies

- Homebrew (for GUI apps and some CLI tools)
- Nixpkgs (main package source)
- 1Password CLI (for secrets management)
- Mason (for Neovim plugin management)
- LazyVim (for Neovim config)
- Stow (for dotfile management)
- Any other CLI tools managed via Nix or Homebrew
