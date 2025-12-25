#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
ZSH_CONFIG_DIR="$HOME/.config/zsh"
ZSH_EXTRAS="$ZSH_CONFIG_DIR/extras.sh"

mkdir -p "$ZSH_CONFIG_DIR"

stow -v -t "$HOME/.config/nvim" nvim

mise install
corepack enable
pnpm add -g @github/copilot
# opencode-ai now managed by mise (configured in home-manager/mise.nix)
pnpm add -g markdown-toc
pnpm add -g @mermaid-js/mermaid-cli

op inject --in-file $SCRIPT_DIR/templates/zsh-extras.sh --out-file "$ZSH_EXTRAS"
