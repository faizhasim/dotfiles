{
  config,
  pkgs,
  lib,
  inputs,
  aiHarnessModelProfile,
  ...
}:
let
  # Model profiles — resolved from flake variable with fallback
  # Returns { provider, primary, fast, largeContext, plan } with provider/ prefix
  models = import ./model-profiles.nix { profileName = aiHarnessModelProfile; };

  # Agent file paths
  agentDir = ./opencode/agent;

  # Function to substitute placeholders in agent files
  substituteAgent =
    file:
    let
      content = builtins.readFile file;
      substituted =
        builtins.replaceStrings
          [ "@PRIMARY_MODEL@" "@FAST_MODEL@" "@LARGE_CONTEXT_MODEL@" ]
          [ models.primary models.fast models.largeContext ]
          content;
    in
    builtins.toFile (baseNameOf file) substituted;

  # Agent definitions with model assignments
  agentFiles = {
    # Primary model agents
    debug = substituteAgent (agentDir + "/debug.md");
    refactor-review = substituteAgent (agentDir + "/refactor-review.md");
    spec-distiller = substituteAgent (agentDir + "/spec-distiller.md");
    infra-platform = substituteAgent (agentDir + "/infra-platform.md");
    test-gen = substituteAgent (agentDir + "/test-gen.md");

    # Fast model agents
    docs-writer = substituteAgent (agentDir + "/docs-writer.md");
    quota-sentry = substituteAgent (agentDir + "/quota-sentry.md");

    # Large context model agents
    creative-ideation = substituteAgent (agentDir + "/creative-ideation.md");
    doc-analyser = substituteAgent (agentDir + "/doc-analyser.md");
    multimodal-ui = substituteAgent (agentDir + "/multimodal-ui.md");
  };
in
{
  # Enable stylix theme integration for opencode
  stylix.targets.opencode.enable = true;

  # Home Manager opencode module
  programs.opencode = {
    enable = true;

    # Using dummy package because binary comes from bun global install
    # (setup-post-nix.sh opencode: bun add -g opencode-ai)
    # Dummy proxies to ~/.bun/bin/opencode and provides version for versionAtLeast checks
    package = pkgs.opencode-dummy;

    # Main opencode configuration (goes to opencode.json)
    # NOTE: Do NOT put theme/tui/keybinds here - they go in separate options below
    settings = {
      autoupdate = true;
      share = "manual";

      provider.github-copilot.models = {
        "claude-sonnet-4.5".options = {
          thinking = {
            type = "enabled";
            budgetTokens = 16000;
          };
        };
        "claude-sonnet-4.6".options = {
          thinking = {
            type = "enabled";
            budgetTokens = 16000;
          };
        };
        "gemini-3.1-pro".options = {
          thinking = {
            type = "enabled";
            budgetTokens = 20000;
          };
        };
        "gpt-5-mini".options = {
          thinking = {
            type = "enabled";
            budgetTokens = 8000;
          };
        };
      };

      # DeepSeek V4 models via opencode-go: use reasoning_effort: "high" for variant high
      # Both V4 Flash and V4 Pro support thinking mode configurable via reasoning_effort
      provider."opencode-go".models = {
        "deepseek-v4-flash".options = {
          reasoning_effort = "high";
        };
        "deepseek-v4-pro".options = {
          reasoning_effort = "high";
        };
      };

      agent = {
        build = {
          description = "Primary dev agent with full tool access";
          mode = "primary";
          model = models.primary;
          temperature = 0.1;
          prompt = "{file:${./opencode/prompts/menatey-rima-mode-1.0.md}}";
          permission = {
            write = "allow";
            edit = "allow";
            bash = "allow";
          };
        };
        plan = {
          description = "Analysis & planning without direct changes";
          mode = "primary";
          model = models.plan or models.primary;
          temperature = 0.3;
          prompt = "{file:${./opencode/prompts/menatey-rima-mode-1.0.md}}";
          permission = {
            write = "deny";
            edit = "deny";
            bash = "deny";
          };
        };
      };

      # Custom command: GitHub PR creation/update with Jira cross-reference + meme
      command.github-pr = {
        description = "Create or update a GitHub PR for the current branch with Jira cross-reference and contextual meme";
        agent = "build";
        subtask = true;
        template = "{file:${./opencode/commands/github-pr.md}}";
      };

      mcp = {
        docker-mcp = {
          type = "local";
          command = [
            "docker"
            "mcp"
            "gateway"
            "run"
          ];
          enabled = true;
        };
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          headers = {
            CONTEXT7_API_KEY = "{env:OPENCODE_CONTEXT7_API}";
          };
        };
        exa = {
          type = "remote";
          url = "https://mcp.exa.ai/mcp";
          enabled = true;
        };
        playwright = {
          type = "local";
          command = [
            "pnpx"
            "@playwright/mcp@latest"
          ];
          enabled = true;
        };
        context-mode = {
          type = "local";
          command = [ "context-mode" ];
          enabled = true;
        };
      };

      # context-mode plugin for lifecycle hooks (sandbox routing, session continuity)
      plugin = [ "context-mode" ];
    };

    # TUI-specific settings (goes to tui.json)
    # stylix will set theme = "stylix" automatically
    tui = {
      scroll_acceleration = {
        enabled = true;
      };
    };
  };

  # Subagent definitions - placed in ~/.config/opencode/agent/
  # These are invoked via @agentname syntax
  home.file = {
    # Subagents (mode: subagent)
    ".config/opencode/agent/debug.md".source = agentFiles.debug;
    ".config/opencode/agent/refactor-review.md".source = agentFiles.refactor-review;
    ".config/opencode/agent/spec-distiller.md".source = agentFiles.spec-distiller;
    ".config/opencode/agent/infra-platform.md".source = agentFiles.infra-platform;
    ".config/opencode/agent/test-gen.md".source = agentFiles.test-gen;
    ".config/opencode/agent/docs-writer.md".source = agentFiles.docs-writer;
    ".config/opencode/agent/quota-sentry.md".source = agentFiles.quota-sentry;
    ".config/opencode/agent/creative-ideation.md".source = agentFiles.creative-ideation;
    ".config/opencode/agent/doc-analyser.md".source = agentFiles.doc-analyser;
    ".config/opencode/agent/multimodal-ui.md".source = agentFiles.multimodal-ui;

    # Plugin: peon-ping TypeScript adapter for OpenCode (pinned to peon-ping v2.8.1)
    ".config/opencode/plugins/peon-ping.ts".source =
      "${inputs.peon-ping}/adapters/opencode/peon-ping.ts";
    # Sound pack: Orc Peon (CESP v1.0, pinned to og-packs v1.1.0)
    ".openpeon/packs/peon" = {
      source = "${inputs.og-packs}/peon";
      recursive = true;
    };

    # Plugin config
    ".config/opencode/peon-ping/config.json".text = builtins.toJSON {
      active_pack = "peon";
      volume = 0.5;
      enabled = true;
      desktop_notifications = true;
      use_sound_effects_device = true;
      categories = {
        "session.start" = true;
        "session.end" = true;
        "task.acknowledge" = true;
        "task.complete" = true;
        "task.error" = true;
        "task.progress" = true;
        "input.required" = true;
        "resource.limit" = true;
        "user.spam" = true;
      };
      spam_threshold = 3;
      spam_window_seconds = 10;
      session_start_cooldown_seconds = 30;
      pack_rotation = [ ];
      debounce_ms = 500;
    };
  };
}
