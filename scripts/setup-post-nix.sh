#!/usr/bin/env bash
# ============================================================================
# setup-post-nix.sh — Post-Nix-setup tasks: pi, nvim, tools, shell config
# ============================================================================
#
# Run this after `darwin-rebuild switch` to finish setup steps that can't or
# shouldn't run inside Nix (npm installs, Stow, 1Password secrets injection).
#
# Usage:
#   setup-post-nix.sh               # Run all targets
#   setup-post-nix.sh pi            # Pi binary + MCP tools (extensions via Nix settings → pi auto-installs)
#   setup-post-nix.sh pi --upgrade  # Force upgrade pi & MCP tools to latest
#   setup-post-nix.sh nvim          # Neovim config (Stow) + tools + zsh extras
#   setup-post-nix.sh mcp           # Private MCP config from 1Password
#   setup-post-nix.sh opencode      # OpenCode AI coding agent (via bun global install)
#
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
ZSH_CONFIG_DIR="$HOME/.config/zsh"
ZSH_EXTRAS="$ZSH_CONFIG_DIR/extras.sh"

# ── Helpers ─────────────────────────────────────────────────────────────────

info() { printf "\033[1;36m==>\033[0m \033[1m%s\033[0m\n" "$*"; }
ok() { printf "\033[1;32m  ✓\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m  ⚠\033[0m %s\n" "$*" >&2; }

# ── Targets ─────────────────────────────────────────────────────────────────

run_pi() {
  local upgrade=false
  for arg in "$@"; do
    case "$arg" in
    --upgrade) upgrade=true ;;
    esac
  done

  if $upgrade; then
    info "Pi.dev — upgrading pi and MCP tools to latest"
    npm install -g \
      "@earendil-works/pi-coding-agent@latest" \
      "pi-mcp-adapter@latest" \
      "context-mode@latest"
  else
    info "Pi.dev — binary install (extensions managed by Nix settings → pi auto-installs)"
    npm install -g \
      "@earendil-works/pi-coding-agent@latest" \
      pi-mcp-adapter \
      context-mode
  fi

  # Remove stale Nix symlink so pi can write auth tokens
  if [ -L "$HOME/.pi/agent/auth.json" ]; then
    rm -f "$HOME/.pi/agent/auth.json"
    ok "Removed stale Nix symlink: ~/.pi/agent/auth.json"
  fi

  # Symlink pi into ~/.local/bin/ (always on PATH via hm-session-vars.sh)
  # so it's available regardless of which mise-managed Node version is active.
  # The lts symlink is maintained by mise and follows the current LTS release.
  if [ -f "$HOME/.local/share/mise/installs/node/lts/bin/pi" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/share/mise/installs/node/lts/bin/pi" "$HOME/.local/bin/pi"
    ok "Symlinked pi to ~/.local/bin/pi (stable, independent of active node version)"
  fi

  ok "Pi binary tools installed (extensions auto-installed by pi on next launch)"
}

# ── Pi extension packages (managed declaratively via Nix settings.json `packages` key) ──
# pi-lens, pi-subagents, pi-plan, context-mode, pi-mcp-adapter,
# @juicesharp/rpiv-todo, @juicesharp/rpiv-ask-user-question, @wierdbytes/pi-peon
# See home-manager/pi.nix for the authoritative list.

run_nvim() {
  info "Neovim — config + tools"

  mkdir -p "$HOME/.config/nvim"
  stow -v -t "$HOME/.config/nvim" nvim
  ok "Nvim config stowed"

  mise install

  pnpm add -g \
    @github/copilot \
    markdown-toc \
    @mermaid-js/mermaid-cli
  ok "PNPM global tools installed"

  mkdir -p "$ZSH_CONFIG_DIR"
  op inject \
    --in-file "$SCRIPT_DIR/templates/zsh-extras.sh" \
    --out-file "$ZSH_EXTRAS"
  ok "Zsh extras injected from 1Password"
}

run_mcp() {
  info "MCP — private MCP config from 1Password"
  mkdir -p "$HOME/.config/mcp"
  op inject \
    --in-file "$SCRIPT_DIR/templates/mcp.json.tpl" \
    --out-file "$HOME/.config/mcp/mcp.json"
  ok "Private MCP config written to ~/.config/mcp/mcp.json"
}

run_opencode() {
  info "OpenCode — AI coding agent (via bun global install)"

  bun add -g opencode-ai

  ok "OpenCode installed (autoupdates handled by bun global)"
}

run_misc() {
  info "Misc — global pnpm tools"

  pnpm add -g \
    @tobilu/qmd
  ok "Misc global pnpm tools installed"
}

run_all() {
  info "Running all targets"
  echo ""
  run_pi
  echo ""
  run_nvim
  echo ""
  run_mcp
  echo ""
  run_opencode
  echo ""
  run_misc
  echo ""
  ok "All targets complete"
}

# ── Dispatch ────────────────────────────────────────────────────────────────

target="${1:-all}"
shift 2>/dev/null || true

case "$target" in
all) run_all "$@" ;;
pi) run_pi "$@" ;;
nvim) run_nvim "$@" ;;
mcp) run_mcp "$@" ;;
opencode) run_opencode "$@" ;;
misc) run_misc "$@" ;;
*)
  echo "Usage: $0 [pi|nvim|mcp|misc|all] [--upgrade]"
  exit 1
  ;;
esac
