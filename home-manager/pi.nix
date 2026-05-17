{
  config,
  pkgs,
  lib,
  inputs,
  aiHarnessModelProfile,
  ...
}:

let
  inherit (config.lib.stylix) colors;

  # Model profiles — resolved from flake variable with fallback
  # Returns { provider, primary, fast, largeContext, plan } with provider/ prefix
  models = import ./model-profiles.nix { profileName = aiHarnessModelProfile; };

  # Helper: pretty-print JSON using jq for human-readable output
  prettyJson =
    attrs:
    pkgs.runCommandLocal "config.json"
      {
        json = builtins.toJSON attrs;
        nativeBuildInputs = [ pkgs.jq ];
        passAsFile = [ "json" ];
      }
      ''
        jq . "$jsonPath" > "$out"
      '';

  # Helper: format base16 color as hex with # prefix for pi.dev theme
  piColor = name: "#${colors.${name}}";

  # Stylix → pi.dev theme: maps base16 Nord palette to pi's 51 color tokens
  # Base16 references: https://github.com/tinted-theming/base16
  piTheme = {
    name = "stylix";
    colors = {
      # Accents & borders
      accent = piColor "base0D";
      border = piColor "base02";
      borderAccent = piColor "base0D";
      borderMuted = piColor "base03";
      success = piColor "base0B";
      error = piColor "base08";
      warning = piColor "base09";
      muted = piColor "base03";
      dim = piColor "base03";

      # Text
      text = piColor "base05";
      thinkingText = piColor "base03";

      # Messages
      selectedBg = piColor "base02";
      userMessageBg = piColor "base01";
      userMessageText = piColor "base05";
      customMessageBg = piColor "base01";
      customMessageText = piColor "base05";
      customMessageLabel = piColor "base0D";

      # Tool boxes
      toolPendingBg = piColor "base00";
      toolSuccessBg = piColor "base00";
      toolErrorBg = piColor "base00";
      toolTitle = piColor "base0D";
      toolOutput = piColor "base05";

      # Markdown
      mdHeading = piColor "base0A";
      mdLink = piColor "base0D";
      mdLinkUrl = piColor "base03";
      mdCode = piColor "base0B";
      mdCodeBlock = piColor "base01";
      mdCodeBlockBorder = piColor "base02";
      mdQuote = piColor "base03";
      mdQuoteBorder = piColor "base02";
      mdHr = piColor "base02";
      mdListBullet = piColor "base0D";

      # Diff
      toolDiffAdded = piColor "base0B";
      toolDiffRemoved = piColor "base08";
      toolDiffContext = piColor "base03";

      # Syntax highlighting
      syntaxKeyword = piColor "base0E";
      syntaxFunction = piColor "base0D";
      syntaxVariable = piColor "base09";
      syntaxString = piColor "base0B";
      syntaxNumber = piColor "base09";
      syntaxType = piColor "base0A";
      syntaxOperator = piColor "base05";
      syntaxPunctuation = piColor "base03";
      syntaxComment = piColor "base03";

      # Thinking levels
      thinkingOff = piColor "base03";
      thinkingLow = piColor "base04";
      thinkingMinimal = piColor "base0D";
      thinkingMedium = piColor "base0B";
      thinkingHigh = piColor "base08";
      thinkingXhigh = piColor "base0F";
      bashMode = piColor "base0B";
      bashOutput = piColor "base05";
    };
  };

  # Pi.dev packages (installed automatically on first startup via ResourceLoader)
  # pi.dev reads settings.json → finds missing packages → runs npm install via npmCommand
  packages = [
    "npm:pi-mcp-adapter" # MCP server integration + Cursor config import
    "npm:context-mode" # Context window protection (sandbox + session continuity)
    "npm:@juicesharp/rpiv-todo" # Persistent todo overlay
    "npm:@juicesharp/rpiv-ask-user-question" # Structured clarification dialogs
    "npm:pi-plan" # Plan mode toggle (read-only guardrails)
    "npm:pi-lens" # LSP, tree-sitter rules, formatting, secrets scan
    "npm:pi-subagents" # Claude Code-style autonomous subagents
    "npm:@wierdbytes/pi-peon" # Orc Peon sound notifications
  ];

  # MCP server configuration (read by pi-mcp-adapter)
  # Servers tagged lifecycle: "lazy" connect on first use; "eager" connect at session start
  mcpServers = {
    docker-mcp = {
      command = "docker";
      args = [
        "mcp"
        "gateway"
        "run"
      ];
      lifecycle = "lazy";
    };
    context7 = {
      url = "https://mcp.context7.com/mcp";
      env = {
        CONTEXT7_API_KEY = "!op read op://Private/context7/api keys/opencode";
      };
      directTools = true; # Register tools directly (no proxy needed)
    };
    exa = {
      url = "https://mcp.exa.ai/mcp";
      env = {
        EXA_API_KEY = "!op read op://Private/Exa/token";
      };
      directTools = true;
    };
    playwright = {
      command = "npx";
      args = [
        "-y"
        "@playwright/mcp@latest"
      ];
      lifecycle = "lazy";
    };
    "context-mode" = {
      command = "context-mode";
      lifecycle = "eager"; # Connect on session start for tool interception
    };
  };
in
{
  # === pi.dev Configuration Files ===

  home.file = {
    # Main settings — global config for all projects
    # Pretty-printed via jq for human readability
    ".pi/agent/settings.json".source = prettyJson {
      defaultProvider = models.provider;
      # defaultModel must NOT include provider prefix — pi combines
      # it with defaultProvider internally. The prefixed version is
      # models.primary (for --model flag), but settings.json needs
      # just the model name.
      defaultModel = models.model;
      theme = "stylix"; # Custom theme generated from Stylix/Nord base16
      # Use mise-managed node for npm operations (matches mise.nix node = "lts")
      npmCommand = [
        "mise"
        "exec"
        "node@lts"
        "--"
        "npm"
      ];
      compaction = {
        enabled = true;
        reserveTokens = 16384;
        keepRecentTokens = 20000;
      };
      retry = {
        enabled = true;
        maxRetries = 3;
      };
      inherit packages;
      enableInstallTelemetry = false;
    };

    # MCP server configuration — standard format used by pi-mcp-adapter
    ".pi/agent/mcp.json".source = prettyJson {
      settings = {
        toolPrefix = "server";
        idleTimeout = 10;
        directTools = false; # Global default; per-server overrides below
      };
      inherit mcpServers;
    };

    # auth.json is NOT managed by Nix — pi.dev writes auth tokens here during /login.
    # A Nix store symlink would be read-only, so we let pi create and manage it.

    # Global agent instructions — same Menatey Rima prompt as opencode
    # Shared file at opencode/prompts/menatey-rima-mode-1.0.md
    ".pi/agent/AGENTS.md".text = builtins.readFile ./opencode/prompts/menatey-rima-mode-1.0.md;

    # Agent definitions directory — for pi-subagents
    ".pi/agent/agents/.keep".text = "# Agent definitions go here as *.md files";

    # Prompt templates directory — for custom system prompt overrides
    ".pi/agent/prompts/.keep".text = "# Prompt templates go here as *.md files";

    # Nord-based theme generated from Stylix base16 palette
    ".pi/agent/themes/stylix.json".source = prettyJson piTheme;
  };

  # opencode-go provider: pi.dev has built-in support, no custom models.json needed.
  # Set OPENCODE_API_KEY in your environment to authenticate.
  # Without it, opencode-go models are listed but API calls fail.

  # === Activation: Install pi.dev (npm-managed, not Homebrew) ===
  # pi is installed via npm (not Homebrew) so `pi update --self` works.
  # Extension packages are installed directly via mise's npm, not via `pi install`,
  # because pi's `npmCommand` setting spawns `mise exec` which requires `mise`
  # on PATH — but during activation, mise is only available at ${pkgs.mise}/bin/mise.
  # Packages are already declared in settings.json, so pi's ResourceLoader finds them.
  home.activation.piExtensions = lib.hm.dag.entryAfter [ "installPackages" ] ''
    if [[ -z "''${DRY_RUN:-}" ]]; then
      echo >&2 "  pi.dev: ensuring binary..."
      ${pkgs.mise}/bin/mise exec --yes node@lts -- \
        npm install -g @earendil-works/pi-coding-agent 2>&1 || true

      # Remove stale Nix symlink — pi needs to write auth tokens here
      [ -L "$HOME/.pi/agent/auth.json" ] && rm -f "$HOME/.pi/agent/auth.json"

      echo >&2 "  pi.dev: ensuring extension packages..."
      for pkg in \
        pi-mcp-adapter \
        context-mode \
        @juicesharp/rpiv-todo \
        @juicesharp/rpiv-ask-user-question \
        pi-plan \
        pi-lens \
        pi-subagents \
        @wierdbytes/pi-peon; do
        ${pkgs.mise}/bin/mise exec --yes node@lts -- \
          npm install -g "''${pkg}" 2>&1 || true
      done
      echo >&2 "  pi.dev: done."
    fi
  '';
}
