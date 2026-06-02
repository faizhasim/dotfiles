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
#   setup-post-nix.sh omp           # OMP plugins + MCP config + verify (binary managed by mise.nix)
#   setup-post-nix.sh runner       # Install/verify GitHub self-hosted runner (macmini01 only)
#   setup-post-nix.sh runner --remove  # Unregister runner and clean up
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


run_omp() {
  info "OMP — plugin setup (binary managed by home-manager/mise.nix)"

  # Ensure omp is installed (idempotent — mise.nix manages the version)
  mise install 2>/dev/null || true

  omp plugin install context-mode
  ok "OMP context-mode plugin installed"

  omp plugin list
  ok "OMP plugins listed"

  omp plugin doctor
  ok "OMP plugin health check complete"

  # ── Hindsight memory backend ──
  # hindsight-local-mcp (managed via launchd) provides the memory server OMP
  # needs for recall/reflect/retain. The server reads the API key on startup
  # from ~/.hindsight/api-key. This step writes it (one-time, no 1Password
  # popup during normal OMP sessions).

  if [[ ! -f "$HOME/.hindsight/api-key" ]]; then
    info "Hindsight memory — writing API key (one-time setup)"

    mkdir -p "$HOME/.hindsight"
    local HS_KEY
    HS_KEY=$(op read op://Private/opencode.ai/api-keys/hindsight 2>/dev/null || true)

    if [[ -n "$HS_KEY" ]]; then
      echo -n "$HS_KEY" > "$HOME/.hindsight/api-key"
      chmod 0600 "$HOME/.hindsight/api-key"
      ok "Hindsight API key written to ~/.hindsight/api-key"
    else
      warn "Could not read opencode-go API key from 1Password."
      warn "Run this manually: op read op://Private/opencode.ai/api-keys/hindsight > ~/.hindsight/api-key"
    fi
  else
    ok "Hindsight API key already present"
  fi

  # ── MCP config seeding ──
  local REF="$HOME/.omp/agent/mcp.json.reference"
  local CUR="$HOME/.omp/agent/mcp.json"

  # If mcp.json.reference exists, merge into writable mcp.json:
  #   - Servers in reference → added/updated with ref values
  #   - Servers in current but not reference → preserved
  #   - auth/oauth fields from current → preserved
  if [ -f "$REF" ]; then
    if [ ! -f "$CUR" ]; then
      cp --no-preserve=mode "$REF" "$CUR"
    else
      local TMP; TMP=$(mktemp)
      jq -s --argjson empty '{}' '
        .[0] as $ref | .[1] as $curr |
        $ref | .mcpServers = (
          (($ref.mcpServers // $empty) * ($curr.mcpServers // $empty | with_entries(
            select(.key | in($ref.mcpServers // $empty) | not)
          )))
          | with_entries(
            if $curr.mcpServers[.key] then
              .value = (
                ($ref.mcpServers[.key] // $empty) +
                (if $curr.mcpServers[.key].auth then {auth: $curr.mcpServers[.key].auth} else $empty end) +
                (if $curr.mcpServers[.key].oauth then {oauth: $curr.mcpServers[.key].oauth} else $empty end)
              )
            else .
            end
          )
        )
      ' "$REF" "$CUR" > "$TMP" && mv "$TMP" "$CUR"
    fi
  fi

  # Resolve !op read secrets in the writable file
  if [ -f "$CUR" ]; then
    jq -r '[.. | strings | select(startswith("!op read ")) | sub("^!op read "; "")] | unique[]' "$CUR" |
    while IFS= read -r ref; do
      local val; val=$(op read "$ref" 2>/dev/null) || continue
      jq --arg old "!op read $ref" --arg new "$val" '
        walk(if type == "string" and . == $old then $new else . end)
      ' "$CUR" > "$CUR.tmp" && mv "$CUR.tmp" "$CUR"
    done
  fi

  ok "OMP mcp.json seeded and secrets resolved"
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

run_runner() {
  local hostname
  hostname="$(hostname -s)"

  if [ "$hostname" != "macmini01" ] && [ "${1:-}" != "--force" ]; then
    warn "Runner setup is only for macmini01 (this host: $hostname). Use --force to override."
    exit 1
  fi

  if [ "${1:-}" = "--remove" ]; then
    info "Removing GitHub Actions runner..."
    if [ -f "$HOME/actions-runner/svc.sh" ]; then
      cd "$HOME/actions-runner"
      ./svc.sh stop 2>/dev/null || true
      ./svc.sh uninstall 2>/dev/null || true
      cd "$OLDPWD"
    fi
    if [ -f "$HOME/actions-runner/config.sh" ]; then
      local token
      token="$(gh api --method POST /repos/faizhasim/dotfiles/actions/runners/registration-token --jq .token 2>/dev/null || echo "")"
      if [ -n "$token" ]; then
      cd "$HOME/actions-runner" && ./config.sh remove --token "$token" 2>/dev/null || true
      cd "$OLDPWD"
      fi
    fi
    rm -rf "$HOME/actions-runner"
    ok "Runner removed"
    exit 0
  fi

  # Already configured and running?
  if [ -f "$HOME/actions-runner/.runner" ] && [ -f "$HOME/actions-runner/.service" ]; then
    if pgrep -f "actions.runner" >/dev/null 2>&1; then
      ok "Runner already configured and running"
      exit 0
      warn "Runner configured but not running — starting service"
      cd "$HOME/actions-runner"
      ./svc.sh start
      cd "$OLDPWD"
      exit 0
    fi
  fi

  # Stale registration without service installed — clean up for fresh install
  if [ -f "$HOME/actions-runner/.runner" ]; then
    warn "Found stale runner configuration (no service installed) — reconfiguring"
    rm -f "$HOME/actions-runner/.runner" "$HOME/actions-runner/.credentials" "$HOME/actions-runner/.credentials_rsaparams"
  fi

  # Prerequisites
  if ! command -v gh &>/dev/null; then
    warn "gh CLI is required. Install via Nix: gh is already in common.nix"
    exit 1
  fi

  # Get registration token
  info "Obtaining runner registration token..."
  local token
  token="$(gh api --method POST /repos/faizhasim/dotfiles/actions/runners/registration-token --jq .token)" || {
    warn "Failed to get registration token. Ensure gh is authenticated."
    exit 1
  }

  # Download and configure
  info "Downloading GitHub Actions runner..."
  mkdir -p "$HOME/actions-runner"
  gh release download --repo actions/runner \
    --pattern 'actions-runner-osx-arm64-*.tar.gz' \
    --dir "$HOME/actions-runner"
  tar xzf "$HOME/actions-runner"/actions-runner-osx-arm64-*.tar.gz -C "$HOME/actions-runner"
  rm -f "$HOME/actions-runner"/actions-runner-osx-arm64-*.tar.gz

  info "Configuring runner..."
  "$HOME/actions-runner/config.sh" \
    --url "https://github.com/faizhasim/dotfiles" \
    --token "$token" \
    --name "macmini01" \
    --labels "self-hosted,mac-mini,macmini01,aarch64-darwin" \
    --unattended \
    --replace

  info "Installing and starting runner service..."
  cd "$HOME/actions-runner"
  ./svc.sh install
  ./svc.sh start
  cd "$OLDPWD"
  ok "GitHub Actions runner installed and running"
}

run_all() {
  info "Running all targets"
  echo ""
  run_nvim
  echo ""
  run_mcp
  echo ""
  run_opencode
  echo ""
  run_omp
  echo ""
  run_misc
  echo ""
  run_skills
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
omp) run_omp "$@" ;;
skills) run_skills "$@" ;;
runner) run_runner "$@" ;;
misc) run_misc "$@" ;;
*)
  echo "Usage: $0 [pi|nvim|mcp|opencode|omp|skills|runner|misc|all] [--upgrade] [--force] [--remove]"
  exit 1
  ;;
esac
