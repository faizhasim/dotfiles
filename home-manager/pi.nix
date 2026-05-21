{
  config,
  pkgs,
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
      borderMuted = piColor "base0D";
      success = piColor "base0B";
      error = piColor "base08";
      warning = piColor "base09";
      # Note: using frost colors (base0C/base0D) instead of base03 for text tokens
      # because terminal transparency washes out the background, making dark gray
      # (#4c566a) unreadable. Frost colors are lighter and remain visible.
      muted = piColor "base0C";
      dim = piColor "base0D";

      # Text
      text = piColor "base06";
      thinkingText = piColor "base0C";

      # Messages
      selectedBg = piColor "base02";
      userMessageBg = piColor "base01";
      userMessageText = piColor "base06";
      customMessageBg = piColor "base01";
      customMessageText = piColor "base06";
      customMessageLabel = piColor "base0D";

      # Tool boxes
      toolPendingBg = piColor "base00";
      toolSuccessBg = piColor "base00";
      toolErrorBg = piColor "base00";
      toolTitle = piColor "base0D";
      toolOutput = piColor "base05";

      # Markdown
      mdHeading = piColor "base0A";
      mdLink = piColor "base0C";
      mdLinkUrl = piColor "base0D";
      mdCode = piColor "base0B";
      mdCodeBlock = piColor "base01";
      mdCodeBlockBorder = piColor "base02";
      mdQuote = piColor "base0C";
      mdQuoteBorder = piColor "base02";
      mdHr = piColor "base02";
      mdListBullet = piColor "base0C";

      # Diff
      toolDiffAdded = piColor "base0B";
      toolDiffRemoved = piColor "base08";
      toolDiffContext = piColor "base0D";

      # Syntax highlighting
      syntaxKeyword = piColor "base0E";
      syntaxFunction = piColor "base0D";
      syntaxVariable = piColor "base09";
      syntaxString = piColor "base0B";
      syntaxNumber = piColor "base09";
      syntaxType = piColor "base0A";
      syntaxOperator = piColor "base06";
      syntaxPunctuation = piColor "base0C";
      syntaxComment = piColor "base0C";

      # Thinking levels
      thinkingOff = piColor "base0D";
      thinkingLow = piColor "base04";
      thinkingMinimal = piColor "base0D";
      thinkingMedium = piColor "base0B";
      thinkingHigh = piColor "base08";
      thinkingXhigh = piColor "base0F";
      bashMode = piColor "base0B";
      bashOutput = piColor "base05";
    };
  };

  # Transparent variant — overrides secondary text with brighter snow storm colors.
  # At 0.8 opacity over white: base04 (#d8dee9) achieves 4.6:1 contrast vs base0C (#88c0d0) at 3.4:1.
  # At 0.9 opacity over white: both achieve >5:1. Using snow+frost gives the best readable hierarchy.
  piThemeTransparent = piTheme // {
    name = "stylix-transparent";
    colors = piTheme.colors // {
      muted = piColor "base04"; # #d8dee9 snow — bright secondary text, 4.6:1 at 0.8 opacity
      dim = piColor "base0C"; # #88c0d0 frost — dimmer than muted, 5.7:1 at 0.9 opacity
      thinkingText = piColor "base04"; # snow — readable thinking blocks
      mdQuote = piColor "base04"; # snow — readable blockquotes
    };
  };

  # Pi.dev extension packages are declared via the settings.json `packages` key
  # and auto-installed by pi on startup. The pi binary and MCP tools
  # (pi-mcp-adapter, context-mode) are installed via `npm install -g` in
  # setup-post-nix.sh — they need to be on PATH.
  # Config files below are the Nix-managed part.

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
        CONTEXT7_API_KEY = "!op read op://Private/wqnec2ehppfchca6xpmbvp6xem/api keys/opencode";
      };
    };
    exa = {
      url = "https://mcp.exa.ai/mcp";
      env = {
        EXA_API_KEY = "!op read op://Private/Exa/token";
      };
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
      theme = "stylix-transparent"; # Transparent-terminal variant — see piThemeTransparent in let block
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
      enableInstallTelemetry = false;
      # Pi extension packages — auto-installed by pi on startup to ~/.pi/agent/npm/
      packages = [
        "npm:pi-lens"
        "npm:pi-subagents"
        "npm:pi-plan"
        "npm:context-mode"
        "npm:pi-mcp-adapter"
        "npm:@juicesharp/rpiv-todo"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:@wierdbytes/pi-peon"
      ];
    };

    # MCP server configuration — standard format used by pi-mcp-adapter.
    # Uses force = true because pi-mcp-adapter sometimes writes directly to
    # this file (via /mcp setup), breaking the Nix store symlink and causing
    # the "would be clobbered by backing up" error on the next rebuild.
    ".pi/agent/mcp.json" = {
      text = builtins.toJSON {
        settings = {
          toolPrefix = "server";
          idleTimeout = 10;
          directTools = false; # Global default; per-server overrides below
        };
        inherit mcpServers;
      };
      force = true;
    };

    # auth.json is NOT managed by Nix — pi.dev writes auth tokens here during /login.
    # A Nix store symlink would be read-only, so we let pi create and manage it.

    # Pi-optimised Menatey Rima prompt — see ./pi/agent/AGENTS.md
    ".pi/agent/AGENTS.md".text = builtins.readFile ./pi/agent/AGENTS.md;

    # Agent definitions directory — pi-subagents auto-discovers built-in agents
    ".pi/agent/agents/.keep".text = "# Custom agent definitions go here as *.md files";

    # Prompt templates directory — for custom system prompt overrides
    ".pi/agent/prompts/.keep".text = "# Prompt templates go here as *.md files";

    # pi-peon sound notification config — static file
    ".pi/agent/peon/config.json".source = ./pi/agent/peon/config.json;

    # Nord-based themes generated from Stylix base16 palette.
    # stylix = original mapping; stylix-transparent = readability-tuned for transparent terminals.
    ".pi/agent/themes/stylix.json".source = prettyJson piTheme;
    ".pi/agent/themes/stylix-transparent.json".source = prettyJson piThemeTransparent;
  };

  # opencode-go provider: pi.dev has built-in support, no custom models.json needed.
  # Set OPENCODE_API_KEY in your environment to authenticate.
  # Without it, opencode-go models are listed but API calls fail.
}
