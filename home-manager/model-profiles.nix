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
    # Full premium access — GitHub Copilot for all roles, cost-tiered by
    # token-metered billing (GH moved off flat premium-request multipliers
    # June 2026). Sonnet 5 for default/plan/task (cheaper AND newer than
    # 4.6: $2/$10 vs $3/$15 per 1M in/out); Opus 5 reserved for `slow` only
    # ($5/$25 — the escalation tier, not a workhorse); Haiku 4.5 for
    # smol/fast/commit (background/frequent calls, $1/$5); Gemini 3.1 Pro
    # preview for vision/design (unchanged).
    # Org has NOT enabled: Moonshot Kimi, xAI Grok, Microsoft MAI-Code.
    github-premium = {
      omp = {
        default = "github-copilot/claude-sonnet-5";
        fast = "github-copilot/claude-haiku-4.5";
        plan = "github-copilot/claude-sonnet-5";
        slow = "github-copilot/claude-opus-5";
        smol = "github-copilot/claude-haiku-4.5";
        task = "github-copilot/claude-sonnet-5";
        commit = "github-copilot/claude-haiku-4.5";
        vision = "github-copilot/gemini-3.1-pro-preview";
        designer = "github-copilot/gemini-3.1-pro-preview";
      };
      opencode = {
        primary = "github-copilot/claude-sonnet-5";
        fast = "github-copilot/claude-haiku-4.5";
        largeContext = "github-copilot/claude-sonnet-5";
        plan = "github-copilot/claude-sonnet-5";
      };
    };

    # Pure OpenCode Go provider (opencode.ai/zen/go). DeepSeek V4 Flash for
    # high-frequency roles ($0.14/$0.28 per 1M — proven "good enough" daily
    # driver in practice, beats its benchmark class on cost-per-task). Kimi
    # K2.7 Code for plan/slow/vision/designer — same price as K2.6
    # ($0.95/$4.00) but +10% agentic / +11-32% coding benchmarks, still
    # multimodal (MoonViT vision encoder) so vision/design stay covered.
    # Replaces both old opencode-go and opencode-go-deepseek profiles.
    opencode-go = {
      omp = {
        default = "opencode-go/deepseek-v4-flash";
        fast = "opencode-go/deepseek-v4-flash";
        plan = "opencode-go/kimi-k2.7-code";
        slow = "opencode-go/kimi-k2.7-code";
        smol = "opencode-go/deepseek-v4-flash";
        task = "opencode-go/deepseek-v4-flash";
        commit = "opencode-go/deepseek-v4-flash";
        vision = "opencode-go/kimi-k2.7-code";
        designer = "opencode-go/kimi-k2.7-code";
      };
      opencode = {
        primary = "opencode-go/deepseek-v4-flash";
        fast = "opencode-go/deepseek-v4-flash";
        largeContext = "opencode-go/deepseek-v4-flash";
        plan = "opencode-go/kimi-k2.7-code";
      };
    };

    # DeepSeek direct provider. V4 Flash for every role — text-only, so
    # vision (image input) falls back to Kimi K2.7 Code, the only multimodal
    # model in this profile. Cheapest reliable daily driver.
    # NOTE: model ids must match what api.deepseek.com currently serves — the
    # old pinned snapshot "deepseek-v4-flash-0731" was dropped from /models
    # and silently broke omp commit's smol resolution (fell back to Copilot).
    deepseek = {
      omp = {
        default = "deepseek/deepseek-v4-flash";
        fast = "deepseek/deepseek-v4-flash";
        plan = "deepseek/deepseek-v4-flash";
        slow = "deepseek/deepseek-v4-flash";
        smol = "deepseek/deepseek-v4-flash";
        task = "deepseek/deepseek-v4-flash";
        commit = "deepseek/deepseek-v4-flash";
        vision = "opencode-go/kimi-k2.7-code";
        designer = "deepseek/deepseek-v4-flash";
      };
      opencode = {
        primary = "deepseek/deepseek-v4-flash";
        fast = "deepseek/deepseek-v4-flash";
        largeContext = "deepseek/deepseek-v4-flash";
        plan = "deepseek/deepseek-v4-flash";
      };
    };

    # Emergency fallback, cheapest reliable tier — NOT free. GH Copilot's
    # premium-request multipliers (where base models were 0x) were replaced
    # by token-metered AI Credits on 2026-06-01: every chat/agent call now
    # draws from the credit pool, including GPT-5 mini ($0.25/$2.00 per 1M).
    # Kept on GPT-5 mini over the marginally cheaper GPT-5.6 Luna
    # ($0.20/$1.20) — this profile is a reliability safety net, not a
    # cost-min target, and mini is the more established tool-calling model.
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
