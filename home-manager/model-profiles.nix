# Model profile definitions — single source of truth for all AI harnesses.
#
# Usage: import ./model-profiles.nix { profileName = aiHarnessModelProfile; }
# Returns: { provider, primary, fast, largeContext, plan }
#          Model IDs include provider/ prefix (e.g. "github-copilot/claude-sonnet-4.6")
#
# Note: There is NO fallback. An invalid profileName causes a predictable eval error.
#
# To verify model IDs at runtime:
#   opencode: use /model inside opencode
#   pi.dev:   run `pi --list-models` and match against these IDs
{
  profileName,
}:

let
  profiles = {
    # Full premium access (Claude Sonnet 4.6, Gemini 2.5 Pro, etc.)
    github-premium = {
      provider = "github-copilot";
      models = {
        primary = "claude-sonnet-4.6";
        fast = "claude-haiku-4.5";
        largeContext = "gemini-2.5-pro";
        plan = "claude-sonnet-4.6";
      };
    };

    # opencode-go models via OPENCODE_API_KEY (Kimi K2.6, GLM 5.1)
    opencode-go = {
      provider = "opencode-go";
      models = {
        primary = "kimi-k2.6";
        fast = "kimi-k2.6";
        largeContext = "glm-5.1";
        plan = "kimi-k2.6";
      };
    };

    # opencode-go with DeepSeek V4 models (flash build, pro plan)
    opencode-go-deepseek = {
      provider = "opencode-go";
      models = {
        primary = "deepseek-v4-flash";
        fast = "deepseek-v4-flash";
        largeContext = "deepseek-v4-pro";
        plan = "deepseek-v4-pro";
      };
    };

    # Emergency fallback to GitHub's free tier models
    github-standard = {
      provider = "github-copilot";
      models = {
        primary = "gpt-4.1";
        fast = "gpt-5-mini";
        largeContext = "gpt-4o";
        plan = "gpt-4.1";
      };
    };
  };

  # No fallback — crash predictably if profileName doesn't match a key
  profile = builtins.getAttr profileName profiles;

  # Add provider/ prefix to a model ID
  prefixed = model: "${profile.provider}/${model}";
in
{
  inherit (profile) provider;
  # Full model IDs with provider/ prefix — for --model flags, opencode, etc.
  primary = prefixed profile.models.primary;
  fast = prefixed profile.models.fast;
  largeContext = prefixed profile.models.largeContext;
  plan = prefixed profile.models.plan;
  # Unprefixed primary model name — for pi settings.json defaultModel
  # Pi expects just "deepseek-v4-flash" when defaultProvider is "opencode-go"
  model = profile.models.primary;
}
