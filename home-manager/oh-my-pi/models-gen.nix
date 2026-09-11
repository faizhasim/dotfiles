# Generate the full copilot-vscode provider config with all models.
{ pkgs }:
let
  yamlFormat = pkgs.formats.yaml { };
  mkYaml = name: attrs: yamlFormat.generate name attrs;
in
mkYaml "models.yml" {
  providers = {
    copilot-vscode = {
      baseUrl = "https://api.githubcopilot.com";
      api = "openai-completions";
      apiKey = "!gh auth token";
      authHeader = true;
      headers = {
        User-Agent = "GitHubCopilotChat/0.35.0";
        Editor-Version = "vscode/1.107.0";
        Editor-Plugin-Version = "copilot-chat/0.35.0";
        Copilot-Integration-Id = "vscode-chat";
        Openai-Intent = "conversation-edits";
        # Unlocks tiered long-context windows (capabilities.limits) + per-tier
        # billing; without it the endpoint serves default-tier limits only
        # (e.g. 264k instead of 1M) — wire/github-copilot.ts.
        X-GitHub-Api-Version = "2026-08-01";
      };
      models = [
        # Chat/completions-routed (live supported_endpoints).
        {
          id = "claude-haiku-4.5";
          name = "Copilot Haiku 4.5 (vscode)";
        }
        {
          id = "claude-sonnet-5";
          name = "Copilot Sonnet 5 (vscode)";
        }
        {
          id = "claude-opus-5";
          name = "Copilot Opus 5 (vscode)";
        }
        {
          id = "claude-opus-4.8";
          name = "Copilot Opus 4.8 (vscode)";
        }
        {
          id = "claude-opus-4.7";
          name = "Copilot Opus 4.7 (vscode)";
        }
        {
          id = "gemini-3.8-flash";
          name = "Copilot Gemini 3.8 Flash (vscode)";
        }
        {
          id = "gemini-3.7-flash";
          name = "Copilot Gemini 3.7 Flash (vscode)";
        }
        {
          id = "gemini-3.6-flash";
          name = "Copilot Gemini 3.6 Flash (vscode)";
        }
        {
          id = "gemini-3.5-flash";
          name = "Copilot Gemini 3.5 Flash (vscode)";
        }
        {
          id = "gpt-4.1";
          name = "Copilot GPT-4.1 (vscode)";
        }
        {
          id = "gpt-4o";
          name = "Copilot GPT-4o (vscode)";
        }
        # Responses-routed (live supported_endpoints; gpt-5.6-luna proven).
        {
          id = "gpt-5-mini";
          name = "Copilot GPT-5 Mini (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-5.3-codex";
          name = "Copilot GPT-5.3 Codex (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-5.4";
          name = "Copilot GPT-5.4 (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-5.4-mini";
          name = "Copilot GPT-5.4 Mini (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-5.5";
          name = "Copilot GPT-5.5 (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-5.6-luna";
          name = "Copilot GPT-5.6 Luna (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-5.6-sol";
          name = "Copilot GPT-5.6 Sol (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-5.6-terra";
          name = "Copilot GPT-5.6 Terra (vscode)";
          api = "openai-responses";
        }
        {
          id = "gpt-6-astra";
          name = "Copilot GPT-6 Astra (vscode)";
          api = "openai-responses";
        }
        {
          id = "grok-4.5";
          name = "Copilot Grok 4.5 (vscode)";
          api = "openai-responses";
        }
        {
          id = "grok-4.6";
          name = "Copilot Grok 4.6 (vscode)";
          api = "openai-responses";
        }
        {
          id = "mai-code-1.1-flash";
          name = "Copilot Mai Flash (vscode)";
          api = "openai-responses";
        }
        {
          id = "mai-code-1-flash-picker";
          name = "Copilot Mai Picker (vscode)";
          api = "openai-responses";
        }
      ];
    };
  };
}
