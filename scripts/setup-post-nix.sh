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
#   setup-post-nix.sh skills        # AI agent skills for Pi and OpenCode
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

run_skills() {
  info "Skills — AI agent skills for Pi and OpenCode"

  # Skills install to the canonical ~/.agents/skills/ dir, which Pi, OpenCode,
  # and all universal agents read from automatically. No --agent flag needed.

  # ── Go + Testing ──
  pnpm dlx skills add jeffallan/claude-skills -s golang-pro -g -y
  pnpm dlx skills add antfu/skills -s vitest -g -y
  pnpm dlx skills add wshobson/agents -s go-concurrency-patterns -g -y
  pnpm dlx skills add anthropics/skills -s webapp-testing -g -y
  pnpm dlx skills add wshobson/agents -s e2e-testing-patterns javascript-testing-patterns -g -y

  # ── Infra: Terraform, K8s, Docker, DevOps ──
  pnpm dlx skills add wshobson/agents -s terraform-module-library -g -y
  pnpm dlx skills add hashicorp/agent-skills -s terraform-test terraform-stacks terraform-search-import -g -y
  pnpm dlx skills add jeffallan/claude-skills -s terraform-engineer kubernetes-specialist devops-engineer -g -y
  pnpm dlx skills add sickn33/antigravity-awesome-skills -s docker-expert -g -y
  pnpm dlx skills add github/awesome-copilot -s multi-stage-dockerfile -g -y

  # ── Python + Rust ──
  pnpm dlx skills add wshobson/agents -s python-performance-optimization python-testing-patterns python-design-patterns -g -y
  pnpm dlx skills add wshobson/agents -s rust-async-patterns -g -y
  pnpm dlx skills add apollographql/skills -s rust-best-practices -g -y

  # ── Git, GitHub & Documentation ──
  pnpm dlx skills add xixu-me/skills -s github-actions-docs -g -y
  pnpm dlx skills add github/awesome-copilot -s git-commit gh-cli documentation-writer -g -y
  # (api-documentation, security-best-practices from supercent-io/skills-template skipped — private repo)

  # ── Security ──
  pnpm dlx skills add wshobson/agents -s security-requirement-extraction -g -y

  # ── AWS & AI/LLM ──
  pnpm dlx skills add aws/agent-toolkit-for-aws -s aws-iam -g -y
  pnpm dlx skills add refoundai/lenny-skills -s building-with-llms -g -y
  pnpm dlx skills add huggingface/skills -s huggingface-llm-trainer -g -y

  # ── Document & Media Processing ──
  pnpm dlx skills add tobi/qmd -g -y
  pnpm dlx skills add anthropics/skills -s pdf pptx -g -y
  pnpm dlx skills add softaworks/agent-toolkit -s mermaid-diagrams -g -y

  # ── Agent Tools & DX ──
  pnpm dlx skills add vercel-labs/agent-browser -g -y
  pnpm dlx skills add vercel-labs/skills -s find-skills -g -y
  pnpm dlx skills add anthropics/skills -s skill-creator -g -y
  pnpm dlx skills add obra/superpowers -s dispatching-parallel-agents -g -y
  pnpm dlx skills add antfu/skills -s pnpm -g -y
  pnpm dlx skills add softaworks/agent-toolkit -s agent-md-refactor -g -y
  pnpm dlx skills add daymade/claude-code-skills -s markdown-tools -g -y ||
    warn "markdown-tools not found in daymade/claude-code-skills (repo restructured)"

  # ── General Development ──
  pnpm dlx skills add wshobson/agents -s typescript-advanced-types architecture-patterns code-review-excellence debugging-strategies architecture-decision-records -g -y
  pnpm dlx skills add softaworks/agent-toolkit -s meme-factory difficult-workplace-conversations -g -y

  ok "Skills installed for Pi and OpenCode agents"
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
  run_skills
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
skills) run_skills "$@" ;;
misc) run_misc "$@" ;;
*)
  echo "Usage: $0 [pi|nvim|mcp|opencode|skills|misc|all] [--upgrade]"
  exit 1
  ;;
esac
