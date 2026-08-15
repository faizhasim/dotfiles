#!/usr/bin/env bash
# ============================================================================
# setup-post-nix.sh — Post-Nix-setup tasks: nvim, tools, shell config
# ============================================================================
#
# Run this after `darwin-rebuild switch` to finish setup steps that can't or
# shouldn't run inside Nix (npm installs, Stow, 1Password secrets injection).
#
# Usage:
#   setup-post-nix.sh                  # Run all targets
#   setup-post-nix.sh nvim             # Neovim config (Stow) + tools + zsh extras
#   setup-post-nix.sh mcp              # Private MCP config from 1Password
#   setup-post-nix.sh opencode         # OpenCode AI coding agent (via bun global install)
#   setup-post-nix.sh herdr            # Install Herdr plugins (worktrunk, floax)
#   setup-post-nix.sh omp              # Oh My Pi agent rules
#   setup-post-nix.sh skills           # Install agent skills
#   setup-post-nix.sh runner           # Install/verify GitHub self-hosted runner (macmini01 only)
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

  pnpm add -g @tobilu/qmd
  ok "qmd installed"

  # Remove stale manual context-mode MCP entry so the plugin can re-register
  # the correct path. The plugin self-registers on first load; a leftover manual
  # entry pointing at the old (now missing) binary would shadow it.
  local MCP_JSON="$HOME/.omp/agent/mcp.json"
  if [ -f "$MCP_JSON" ] && jq -e '.mcpServers["context-mode"]' "$MCP_JSON" >/dev/null 2>&1; then
    jq 'del(.mcpServers["context-mode"])' "$MCP_JSON" >"$MCP_JSON.tmp" && mv "$MCP_JSON.tmp" "$MCP_JSON"
    ok "Removed stale context-mode MCP entry (plugin will re-register)"
  fi

  omp plugin install context-mode
  ok "context-mode plugin installed"

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
      echo -n "$HS_KEY" >"$HOME/.hindsight/api-key"
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
      local TMP
      TMP=$(mktemp)
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
      ' "$REF" "$CUR" >"$TMP" && mv "$TMP" "$CUR"
    fi
  fi

  # Resolve !op read secrets in the writable file
  if [ -f "$CUR" ]; then
    jq -r '[.. | strings | select(startswith("!op read ")) | sub("^!op read "; "")] | unique[]' "$CUR" |
      while IFS= read -r ref; do
        local val
        val=$(op read "$ref" 2>/dev/null) || continue
        jq --arg old "!op read $ref" --arg new "$val" '
        walk(if type == "string" and . == $old then $new else . end)
      ' "$CUR" >"$CUR.tmp" && mv "$CUR.tmp" "$CUR"
      done
  fi

  ok "OMP mcp.json seeded and secrets resolved"
}

run_skills() {
  info "Skills — AI agent skills"

  # Workaround for vercel-labs/skills#1352: skills CLI includes PromptScript in
  # its universal-agent fanout, which fails on global installs. Passing explicit
  # --agent bypasses that path and limits installation to the agents in use.
  # Array form required — "quoted string" passes as one arg, breaking the flag.
  #
  # Only opencode needed: installs to ~/.agents/skills/ which OMP reads natively
  # via its "agents" provider (AGENT_DIR_CANDIDATES = [".agent", ".agents"]).
  # --agent pi (~/.pi/agent/skills/) is redundant; "omp" is not a valid agent ID.
  local -a AGENTS=(--agent opencode)

  # ── Document Skills ──
  pnpm dlx skills add anthropics/skills -s pdf pptx -g -y "${AGENTS[@]}"

  # ── Example Skills ──
  pnpm dlx skills add anthropics/skills -s skill-creator webapp-testing -g -y "${AGENTS[@]}"

  # ── Mattpocock Skills — Engineering ──
  pnpm dlx skills add mattpocock/skills -s \
    ask-matt code-review codebase-design diagnosing-bugs domain-modeling \
    grill-with-docs implement improve-codebase-architecture prototype research \
    resolving-merge-conflicts setup-matt-pocock-skills tdd to-spec to-tickets \
    triage wayfinder wizard \
    -g -y "${AGENTS[@]}"

  # ── Mattpocock Skills — Productivity ──
  pnpm dlx skills add mattpocock/skills -s \
    grill-me grilling handoff teach to-questionnaire wait-what writing-for-agents \
    -g -y "${AGENTS[@]}"

  # ── General: Languages — Go ──
  pnpm dlx skills add jeffallan/claude-skills -s golang-pro -g -y "${AGENTS[@]}"
  pnpm dlx skills add wshobson/agents -s go-concurrency-patterns -g -y "${AGENTS[@]}"

  # ── General: Languages — Rust ──
  pnpm dlx skills add wshobson/agents -s rust-async-patterns -g -y "${AGENTS[@]}"
  pnpm dlx skills add apollographql/skills -s rust-best-practices -g -y "${AGENTS[@]}"

  # ── General: Languages — Python ──
  pnpm dlx skills add wshobson/agents -s python-design-patterns python-performance-optimization python-testing-patterns -g -y "${AGENTS[@]}"

  # ── General: Languages — TypeScript / JavaScript ──
  pnpm dlx skills add wshobson/agents -s typescript-advanced-types -g -y "${AGENTS[@]}"
  pnpm dlx skills add antfu/skills -s pnpm vitest -g -y "${AGENTS[@]}"
  pnpm dlx skills add wshobson/agents -s javascript-testing-patterns e2e-testing-patterns -g -y "${AGENTS[@]}"

  # ── General: Infrastructure — Terraform ──
  pnpm dlx skills add wshobson/agents -s terraform-module-library -g -y "${AGENTS[@]}"
  pnpm dlx skills add hashicorp/agent-skills -s terraform-test terraform-stacks terraform-search-import -g -y "${AGENTS[@]}"

  # ── General: Infrastructure — Containers & Cloud ──
  pnpm dlx skills add jeffallan/claude-skills -s terraform-engineer kubernetes-specialist devops-engineer -g -y "${AGENTS[@]}"
  pnpm dlx skills add sickn33/antigravity-awesome-skills -s docker-expert -g -y "${AGENTS[@]}"
  pnpm dlx skills add github/awesome-copilot -s multi-stage-dockerfile -g -y "${AGENTS[@]}"
  pnpm dlx skills add aws/agent-toolkit-for-aws -s aws-iam -g -y "${AGENTS[@]}"

  # ── General: Git, GitHub & Tooling ──
  pnpm dlx skills add github/awesome-copilot -s git-commit documentation-writer -g -y "${AGENTS[@]}"
  pnpm dlx skills add xixu-me/skills -s github-actions-docs -g -y "${AGENTS[@]}"
  pnpm dlx skills add https://github.com/max-sixty/worktrunk --skill worktrunk
  pnpm dlx skills add ogulcancelik/herdr -s herdr -g -y "${AGENTS[@]}"
  pnpm dlx skills add agavra/tuicr -s tuicr -g -y "${AGENTS[@]}"

  # ── General: AI & LLMs ──
  pnpm dlx skills add huggingface/skills -s huggingface-llm-trainer -g -y "${AGENTS[@]}"

  # ── General: Agent Tools & DX ──
  pnpm dlx skills add vercel-labs/agent-browser -g -y "${AGENTS[@]}"
  pnpm dlx skills add vercel-labs/skills -s find-skills -g -y "${AGENTS[@]}"
  pnpm dlx skills add obra/superpowers -s dispatching-parallel-agents -g -y "${AGENTS[@]}"
  pnpm dlx skills add softaworks/agent-toolkit -s agent-md-refactor -g -y "${AGENTS[@]}"
  pnpm dlx skills add tobi/qmd -g -y "${AGENTS[@]}"

  # ── General: Docs & Media ──
  pnpm dlx skills add softaworks/agent-toolkit -s mermaid-diagrams -g -y "${AGENTS[@]}"

  # ── General: Security ──
  pnpm dlx skills add wshobson/agents -s security-requirement-extraction -g -y "${AGENTS[@]}"

  # ── General: Architecture & Development ──
  pnpm dlx skills add wshobson/agents -s architecture-decision-records architecture-patterns code-review-excellence debugging-strategies -g -y "${AGENTS[@]}"
  pnpm dlx skills add softaworks/agent-toolkit -s meme-factory difficult-workplace-conversations -g -y "${AGENTS[@]}"

  ok "Skills installed for Pi and OpenCode agents"
}

run_herdr() {
  info "Herdr — plugin setup (binary managed by home-manager/mise.nix)"

  # Ensure herdr is installed (idempotent — mise.nix manages the version)
  mise install 2>/dev/null || true

  local herdr_bin
  herdr_bin="$(mise which herdr 2>/dev/null || command -v herdr)"

  if [ -z "$herdr_bin" ] || [ ! -x "$(command -v "$herdr_bin")" ]; then
    warn "herdr binary not found — skipping plugin install"
    warn "Run: mise use -g herdr, then retry"
    return
  fi

  # ── worktrunk plugin ──
  if "$herdr_bin" plugin list 2>/dev/null | grep -qF "worktrunk"; then
    ok "herdr-worktrunk plugin already installed"
  else
    info "Installing herdr-worktrunk..."
    "$herdr_bin" plugin install devashish2203/herdr-worktrunk --yes 2>&1 || warn "herdr-worktrunk install failed (non-fatal)"
  fi

  # ── floax plugin (needs Rust) ──
  if "$herdr_bin" plugin list 2>/dev/null | grep -qF "herdr-floax"; then
    ok "herdr-floax plugin already installed"
  else
    if command -v cargo &>/dev/null; then
      info "Installing herdr-floax..."
      "$herdr_bin" plugin install Tyru5/herdr-floax --yes 2>&1 || warn "herdr-floax install failed (non-fatal)"
    else
      warn "  Install Rust toolchain: rustup install stable, then run: setup-post-nix.sh herdr"
    fi
  fi

  # ── Verify ──
  "$herdr_bin" plugin list
  ok "Herdr plugins listed"
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
    else
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
  run_skills
  echo ""
  run_herdr
  echo ""

  ok "All targets complete"
}

# ── Dispatch ────────────────────────────────────────────────────────────────

target="${1:-all}"
shift 2>/dev/null || true
case "$target" in
all) run_all "$@" ;;
nvim) run_nvim "$@" ;;
mcp) run_mcp "$@" ;;
opencode) run_opencode "$@" ;;
herdr) run_herdr "$@" ;;
omp) run_omp "$@" ;;
skills) run_skills "$@" ;;
runner) run_runner "$@" ;;
*)
  echo "Usage: $0 [nvim|mcp|opencode|herdr|omp|skills|runner|all] [--force] [--remove]"
  exit 1
  ;;
esac
