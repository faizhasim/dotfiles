# Model profile definitions — single source of truth for all AI harnesses.
#
# Usage: import ./model-profiles.nix { profileName = aiHarnessModelProfile; }
# Returns: { omp: { default, fast, plan, slow, smol, task, commit, vision, designer },
#            opencode: { primary, fast, largeContext, plan } }
#          Model IDs include provider/ prefix (e.g. "github-copilot/claude-sonnet-4.6")
#
# Note: There is NO fallback. An invalid profileName causes a predictable eval error.
{
  profileName,
}:

let
  profiles = {
    # Full premium access — GitHub Copilot for all roles.
    # Sonnet 4.6 for primary/slow/plan/task; Haiku 4.5 for fast/commit;
    # Gemini 3.1 Pro for vision/design.
    github-premium = {
      omp = {
        default = "github-copilot/claude-sonnet-4.6";
        fast = "github-copilot/claude-haiku-4.5";
        plan = "github-copilot/claude-sonnet-4.6";
        slow = "github-copilot/claude-sonnet-4.6";
        smol = "github-copilot/claude-sonnet-4.6";
        task = "github-copilot/claude-sonnet-4.6";
        commit = "github-copilot/claude-haiku-4.5";
        vision = "github-copilot/gemini-3.1-pro-preview";
        designer = "github-copilot/gemini-3.1-pro-preview";
      };
      opencode = {
        primary = "github-copilot/claude-sonnet-4.6";
        fast = "github-copilot/claude-haiku-4.5";
        largeContext = "github-copilot/claude-sonnet-4.6";
        plan = "github-copilot/claude-sonnet-4.6";
      };
    };

    # Pure OpenCode Go provider.
    # DeepSeek V4 Flash daily driver, Kimi K2.6 for vision/design.
    # Replaces both old opencode-go and opencode-go-deepseek profiles.
    opencode-go = {
      omp = {
        default = "opencode-go/deepseek-v4-flash";
        fast = "opencode-go/deepseek-v4-flash";
        plan = "opencode-go/deepseek-v4-flash";
        slow = "opencode-go/deepseek-v4-flash";
        smol = "opencode-go/deepseek-v4-flash";
        task = "opencode-go/deepseek-v4-flash";
        commit = "opencode-go/deepseek-v4-flash";
        vision = "opencode-go/kimi-k2.6";
        designer = "opencode-go/kimi-k2.6";
      };
      opencode = {
        primary = "opencode-go/deepseek-v4-flash";
        fast = "opencode-go/deepseek-v4-flash";
        largeContext = "opencode-go/deepseek-v4-flash";
        plan = "opencode-go/deepseek-v4-flash";
      };
    };

    # Emergency fallback to GitHub's free tier (GPT-5 mini only).
    # GPT-4.1 deprecated June 2026 — not included.
    github-standard = {
      omp = {
        default = "github-copilot/gpt-5-mini";
        fast = "github-copilot/gpt-5-mini";
        plan = "github-copilot/gpt-5-mini";
        slow = "github-copilot/gpt-5-mini";
        smol = "github-copilot/gpt-5-mini";
        task = "github-copilot/gpt-5-mini";
        commit = "github-copilot/gpt-5-mini";
        vision = "github-copilot/gpt-5-mini";
        designer = "github-copilot/gpt-5-mini";
      };
      opencode = {
        primary = "github-copilot/gpt-5-mini";
        fast = "github-copilot/gpt-5-mini";
        largeContext = "github-copilot/gpt-5-mini";
        plan = "github-copilot/gpt-5-mini";
      };
    };
  };
in
builtins.getAttr profileName profiles
