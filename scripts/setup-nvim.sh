#!/usr/bin/env bash

set -euo pipefail

stow -v -t "$HOME/.config/nvim" nvim

mise install
corepack enable
pnpm add -g @github/copilot
pnpm add -g markdown-toc
