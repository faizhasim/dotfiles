# Model profile definitions — single source of truth for all AI harnesses.
#
# Usage: import ./model-profiles.nix { profileName = aiHarnessModelProfile; }
# Returns: { omp: { default, fast, plan, slow, smol, task, commit, vision, designer },
#            opencode: { primary, fast, largeContext, plan } }
#          Model IDs include provider/ prefix (e.g. "copilot-vscode/claude-sonnet-5")
#
# Note: There is NO fallback. An invalid profileName causes a predictable eval error.
{
  profileName,
}:

let
  profiles = {
    # Full premium access — Copilot via the copilot-vscode custom provider
    # (VS Code Chat integrator identity), roles split by evidence/price/context
    # (Sept 2026 review): Luna ($0.20/$1.20, 328k live
    # ctx, 84.7% Terminal-Bench 2.0) carries all high-frequency + long-loop
    # roles; Sonnet 5 (85.2% SWE-bench Verified) keeps plan judgment; Terra
    # ($2/$12, 400k live ctx, 87.4% TB2.0) is the escalation tier; Gemini 3.8
    # Flash does vision/design (10 images, promo $0.75/$3.75 thru Dec 31).
    # Haiku 4.5 infers but is outside the allowlisted set — dropped.
    github-premium = {
      omp = {
        default = "copilot-vscode/gpt-5.6-luna";
        fast = "copilot-vscode/gpt-5.6-luna";
        plan = "copilot-vscode/claude-sonnet-5";
        slow = "copilot-vscode/gpt-5.6-terra";
        smol = "copilot-vscode/gpt-5.6-luna";
        task = "copilot-vscode/gpt-5.6-luna";
        commit = "copilot-vscode/gpt-5.6-luna";
        vision = "copilot-vscode/gemini-3.8-flash";
        designer = "copilot-vscode/gemini-3.8-flash";
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
        default = "copilot-vscode/gpt-5-mini";
        fast = "copilot-vscode/gpt-5-mini";
        plan = "copilot-vscode/gpt-5-mini";
        slow = "copilot-vscode/gpt-5-mini";
        smol = "copilot-vscode/gpt-5-mini";
        task = "copilot-vscode/gpt-5-mini";
        commit = "copilot-vscode/gpt-5-mini";
        vision = "copilot-vscode/gpt-5-mini";
        designer = "copilot-vscode/gpt-5-mini";
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
