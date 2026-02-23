{ lib, ... }:
{
  programs.opencode = {
    enable = true;
    # CRITICAL: Set to null - binary comes from Homebrew, not Nix
    # Installed via darwin/homebrew/common.nix for reliable autoupdate
    package = null;

    settings = {
      theme = lib.mkForce "nord";
      autoupdate = true; # Works with Homebrew installation
      share = "manual";

      provider.github-copilot.models."claude-sonnet-4.5".options = {
        thinking = {
          type = "enabled";
          budgetTokens = 16000;
        };
      };

      agent = {
        build = {
          description = "Primary dev agent with full tool access";
          mode = "primary";
          model = "github-copilot/claude-sonnet-4.5";
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
          model = "github-copilot/claude-sonnet-4.5";
          temperature = 0.3;
          prompt = "{file:${./opencode/prompts/menatey-rima-mode-1.0.md}}";
          permission = {
            write = "deny";
            edit = "deny";
            bash = "deny";
          };
        };
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
      };

      tui.scroll_acceleration.enabled = true;
    };

    # Custom agents (10 files)
    agents = {
      creative-ideation = ./opencode/agent/creative-ideation.md;
      debug = ./opencode/agent/debug.md;
      doc-analyser = ./opencode/agent/doc-analyser.md;
      docs-writer = ./opencode/agent/docs-writer.md;
      infra-platform = ./opencode/agent/infra-platform.md;
      multimodal-ui = ./opencode/agent/multimodal-ui.md;
      quota-sentry = ./opencode/agent/quota-sentry.md;
      refactor-review = ./opencode/agent/refactor-review.md;
      spec-distiller = ./opencode/agent/spec-distiller.md;
      test-gen = ./opencode/agent/test-gen.md;
    };
  };
}
