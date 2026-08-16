{
  config,
  pkgs,
  lib,
  aiHarnessModelProfile,
  ...
}:

let
  yamlFormat = pkgs.formats.yaml { };
  mkYaml = name: attrs: yamlFormat.generate name attrs;

  # Model profiles — shared with pi.nix, opencode.nix
  # Change aiHarnessModelProfile in flake.nix → all harnesses update.
  models = import ./model-profiles.nix { profileName = aiHarnessModelProfile; };

  # OMP model-role fragment — computed from models.omp (model-profiles.nix),
  # patched into the live ~/.omp/agent/config.yml on every activation (see
  # ompConfigBootstrap below) so it always reflects the current
  # aiHarnessModelProfile choice, independent of any other local drift.
  modelRolesFragment = mkYaml "omp-model-roles.yml" {
    modelRoles = {
      inherit (models.omp) default;
      inherit (models.omp)
        fast
        plan
        slow
        smol
        task
        commit
        vision
        designer
        ;
    };
  };

  # ── dark-nord-enhanced theme ────────────────────────────────────────
  # Fixes nord3 (#4c566a) on nord0 (#2e3440) — only ~1.5:1 contrast.
  # _muted/dim are brighter polar-night variants that clear WCAG AA.
  _c = config.lib.stylix.colors.withHashtag;
  _muted = "#9fb6cc"; # 4.84:1 contrast on #2e3440
  _dim = "#7a92a8"; # 3.15:1 contrast on #2e3440

  nordEnhancedTheme = builtins.toJSON {
    name = "dark-nord-enhanced";
    vars = {
      nord0 = "#2e3440";
      nord1 = "#3b4252";
      nord2 = "#434c5e";
      nord3 = "#4c566a";
      nord4 = "#d8dee9";
      nord5 = "#e5e9f0";
      nord6 = "#eceff4";
      nord7 = "#8fbcbb";
      nord8 = "#88c0d0";
      nord9 = "#81a1c1";
      nord10 = "#5e81ac";
      nord11 = "#bf616a";
      nord12 = "#d08770";
      nord13 = "#ebcb8b";
      nord14 = "#a3be8c";
      nord15 = "#b48ead";
    };
    colors = {
      accent = "nord8";
      border = "nord10";
      borderAccent = "nord8";
      borderMuted = "nord2";
      success = "nord14";
      error = "nord11";
      warning = "nord13";
      muted = _muted;
      dim = _dim;
      text = "";
      thinkingText = _muted;
      selectedBg = "nord1";
      userMessageBg = "nord1";
      userMessageText = "";
      customMessageBg = "#3c384f";
      customMessageText = "";
      customMessageLabel = "nord15";
      toolPendingBg = "nord1";
      toolSuccessBg = "nord0";
      toolErrorBg = "#3b2f31";
      toolTitle = "nord8";
      toolOutput = _muted;
      mdHeading = "nord8";
      mdLink = "nord8";
      mdLinkUrl = _dim;
      mdCode = "nord7";
      mdCodeBlock = "nord4";
      mdCodeBlockBorder = "nord2";
      mdQuote = "nord4";
      mdQuoteBorder = _dim;
      mdHr = "nord2";
      mdListBullet = "nord9";
      toolDiffAdded = "nord14";
      toolDiffRemoved = "nord11";
      toolDiffContext = _dim;
      syntaxComment = _dim;
      syntaxKeyword = "nord9";
      syntaxFunction = "nord8";
      syntaxVariable = "nord4";
      syntaxString = "nord14";
      syntaxNumber = "nord15";
      syntaxType = "nord7";
      syntaxOperator = "nord9";
      syntaxPunctuation = "nord6";
      thinkingOff = "nord2";
      thinkingMinimal = _dim;
      thinkingLow = "nord10";
      thinkingMedium = "nord9";
      thinkingHigh = "nord15";
      thinkingXhigh = "nord7";
      bashMode = "nord8";
      pythonMode = "#f0c040";
      statusLineBg = "nord0";
      statusLineSep = "nord3";
      statusLineModel = "nord15";
      statusLinePath = "nord7";
      statusLineGitClean = "nord14";
      statusLineGitDirty = "nord13";
      statusLineContext = "nord9";
      statusLineSpend = "nord8";
      statusLineStaged = "nord14";
      statusLineDirty = "nord13";
      statusLineUntracked = "nord8";
      statusLineOutput = "nord12";
      statusLineCost = "nord12";
      statusLineSubagents = "nord8";
    };
    export = {
      pageBg = "nord0";
      cardBg = "nord1";
      infoBg = "nord2";
    };
  };

in
{
  home.file = {

    # ── Keybindings ──────────────────────────────────────────────
    # STT toggle moved off Alt+H (taken by AeroSpace for focus left).
    # Alt+S is unused by both AeroSpace and OMP defaults.
    # NOTE: Uses JSON format (not YAML) — OMP 15.7.2 binary only reads keybindings.json.
    # Lives in-repo (home-manager/oh-my-pi/keybindings.json) via an
    # out-of-store symlink — edits are live immediately, no rebuild needed.
    ".omp/agent/keybindings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/faizhasim/dotfiles/home-manager/oh-my-pi/keybindings.json";
      force = true;
    };

    # ── Stream rules ────────────────────────────────────────────────
    # Rules activate on violation only — no permanent context tax.
    ".omp/agent/rules/guardrails.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/faizhasim/dotfiles/home-manager/oh-my-pi/rules/guardrails.md";
      force = true;
    };
    ".omp/agent/rules/pkg-mgr-auth.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/faizhasim/dotfiles/home-manager/oh-my-pi/rules/pkg-mgr-auth.md";
      force = true;
    };
    ".omp/agent/rules/herdr.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/faizhasim/dotfiles/home-manager/oh-my-pi/rules/herdr.md";
      force = true;
    };
    # Always-apply rules (active every session)
    ".omp/agent/rules/research-protocol.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/faizhasim/dotfiles/home-manager/oh-my-pi/rules/research-protocol.md";
      force = true;
    };

    # ═══════════════════════════════════════════════════════════════════
    # ~/.omp/agent/mcp.json  (seed reference managed by Nix)
    # ═══════════════════════════════════════════════════════════════════
    #
    # Nix writes the reference file with base server entries. The post-nix
    # script (setup-post-nix.sh omp-oauth) merges it into the writable
    # mcp.json, resolves !op read secrets, and OMP's /mcp reauth adds
    # auth/oauth configs that survive future rebuilds.
    #
    ".omp/agent/mcp.json.reference" = {
      text = builtins.toJSON {
        mcpServers = {
          docker-mcp = {
            command = "docker";
            args = [
              "mcp"
              "gateway"
              "run"
            ];
          };
          context7 = {
            type = "http";
            url = "https://mcp.context7.com/mcp";
            env = {
              CONTEXT7_API_KEY = "!op read op://Private/context7/api-keys/opencode";
            };
          };
          qmd = {
            command = "qmd";
            args = [ "mcp" ];
          };
          Atlassian = {
            type = "http";
            url = "!op read op://Private/mcp-info/mcp-atlassian-url";
          };
          Backstage = {
            type = "http";
            url = "!op read op://Private/mcp-info/mcp-backstage-url";
          };
          Buildkite = {
            type = "http";
            url = "!op read op://Private/mcp-info/buildkite-mcp-url";
            headers = {
              X-Buildkite-Toolsets = "!op read op://Private/mcp-info/buildkite-mcp-toolsets";
            };
          };
          GitHub = {
            type = "http";
            url = "!op read op://Private/mcp-info/mcp-github-url";
          };
          Glean = {
            type = "http";
            url = "!op read op://Private/mcp-info/mcp-glean-url";
          };
          Figma = {
            type = "http";
            url = "!op read op://Private/mcp-info/mcp-figma-url";
          };
          Datadog = {
            type = "http";
            url = "!op read op://Private/mcp-info/datadog-mcp-url";
            headers = {
              DD-SITE = "!op read op://Private/mcp-info/datadog-mcp-site";
              DD-API-KEY = "!op read op://Private/mcp-info/datadog-mcp-dd-api-key";
              DD-APPLICATION-KEY = "!op read op://Private/mcp-info/datadog-mcp-dd-application-key";
            };
          };
        };
      };
      force = true;
    };

    # ── Custom OMP theme ─────────────────────────────────────────────
    # dark-nord-enhanced: nord palette with readable muted/dim/toolOutput.
    # nord3 (#4c566a) on nord0 (#2e3440) is ~1.5:1 — fixed to ≥4.84:1.
    ".omp/agent/themes/dark-nord-enhanced.json" = {
      text = nordEnhancedTheme;
    };
  };

  # Seed ~/.omp/agent/config.yml from the hand-maintained template on first
  # activation only — after that, every OTHER key is left alone forever, so
  # /settings writes persist across rebuilds instead of being silently
  # discarded. modelRoles is the one exception: it's re-patched in place on
  # every activation (via yq), since it's computed from models.omp
  # (model-profiles.nix / aiHarnessModelProfile) and must always reflect the
  # current flake choice, shared with pi.nix/opencode.nix.
  home.activation.ompConfigBootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    AGENT_DIR="$HOME/.omp/agent"
    LIVE="$AGENT_DIR/config.yml"
    run mkdir -p "$AGENT_DIR"
    if [ ! -f "$LIVE" ]; then
      run install -m 0644 ${./oh-my-pi/config.yml} "$LIVE"
    fi
    run ${pkgs.yq-go}/bin/yq eval -i '.modelRoles = load("${modelRolesFragment}").modelRoles' "$LIVE"
  '';

}
