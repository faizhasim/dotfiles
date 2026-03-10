# OpenCode Subagent Model Comparison

**Last Updated**: March 10, 2026
**Purpose**: Evaluate model options for OpenCode subagents with focus on coding, document analysis, and cost-effectiveness.

---

## Executive Summary

### Quick Recommendations

| Use Case                             | Primary Recommendation    | Alternative         |
| ------------------------------------ | ------------------------- | ------------------- |
| **Primary coding agent**             | Claude Sonnet 4.6 ⭐      | Claude Sonnet 4.5   |
| **Large document analysis**          | Gemini 3.1 Pro ⭐         | Gemini 2.5 Pro      |
| **Quick code generation**            | GPT-5-mini ⭐             | Claude Haiku 4.5    |
| **Bulk operations (cost-sensitive)** | GPT-5-mini                | Claude Haiku 4.5    |
| **Debug/refactoring**                | Claude Sonnet 4.6         | Gemini 3.1 Pro      |
| **Creative ideation**                | Claude Sonnet 4.6         | Claude Opus 4.5     |

---

## Model Specifications

### 1. Claude Sonnet 4.6 (github-copilot) ⭐ NEW

**Context Window**: 200K tokens (configurable, can extend beyond for >200K prompts)

**Pricing (via Anthropic Direct API)**:
- Input: $3/MTok (≤200K), $6/MTok (>200K)
- Output: $15/MTok (≤200K), $22.50/MTok (>200K)
- Prompt caching: Write $3.75/MTok, Read $0.30/MTok (≤200K)

**GitHub Copilot Cost Multiplier**: ~2-3x effective cost vs direct API

**Benchmarks**:
- **HumanEval**: ~70% (estimated, improved from 4.5)
- **MMLU**: Frontier-level
- **GPQA (Graduate-level reasoning)**: State-of-the-art
- **Speed**: Similar to 4.5 (2x faster than Claude 3 Opus)
- **Coding**: Exceptional - enhanced multi-step workflows

**Strengths**:
- Latest improvements over 4.5
- Best-in-class for agentic coding tasks
- Excellent at multi-step reasoning and tool use
- Strong context understanding for long files
- Natural, conversational output quality

**Limitations**:
- Higher cost than Haiku/GPT-5-mini for simple tasks
- Rate limits on GitHub Copilot may be restrictive

**Best For**:
- Primary coding agent (current choice ✅)
- Complex refactoring with multiple file changes
- Code generation requiring deep context understanding
- Tasks requiring natural language explanations

---

### 2. Claude Sonnet 4.5 (github-copilot)

**Context Window**: 200K tokens (configurable, can extend beyond for >200K prompts)

**Pricing (via Anthropic Direct API)**:

- Input: $3/MTok (≤200K), $6/MTok (>200K)
- Output: $15/MTok (≤200K), $22.50/MTok (>200K)
- Prompt caching: Write $3.75/MTok, Read $0.30/MTok (≤200K)

**GitHub Copilot Cost Multiplier**: ~2-3x effective cost vs direct API

**Benchmarks**:

- **HumanEval**: 64% (agentic coding evaluation)
- **MMLU**: Frontier-level (specific score not disclosed in latest release)
- **GPQA (Graduate-level reasoning)**: State-of-the-art
- **Speed**: 2x faster than Claude 3 Opus
- **Coding**: Exceptional - purpose-built for multi-step workflows

**Strengths**:

- Best-in-class for agentic coding tasks
- Excellent at multi-step reasoning and tool use
- Strong context understanding for long files
- Natural, conversational output quality
- Artifact generation for iterative work

**Limitations**:

- Higher cost than Haiku for simple tasks
- Rate limits on GitHub Copilot may be restrictive
- Not the absolute cheapest for bulk operations

**Best For**:

- Primary coding agent (current choice ✅)
- Complex refactoring with multiple file changes
- Code generation requiring deep context understanding
- Tasks requiring natural language explanations

---

### 2. Claude Haiku 4.5 (github-copilot)

**Context Window**: 200K tokens

**Pricing (via Anthropic Direct API)**:

- Input: $1/MTok
- Output: $5/MTok
- Prompt caching: Write $1.25/MTok, Read $0.10/MTok

**GitHub Copilot Cost Multiplier**: ~2-3x effective cost vs direct API

**Benchmarks**:

- **HumanEval**: Expected ~45-55% (based on Haiku 3.5 baseline)
- **MMLU**: Good performance, below Sonnet
- **Speed**: Fastest in Claude family
- **Latency**: Sub-second response times

**Strengths**:

- 5x cheaper than Sonnet 4.5 on input, 3x on output
- Extremely fast responses
- Good enough for straightforward coding tasks
- Excellent for bulk operations

**Limitations**:

- Lower reasoning capability than Sonnet
- May struggle with complex multi-file refactoring
- Less nuanced understanding of ambiguous requirements

**Best For**:

- Simple code generation tasks
- Quick documentation updates
- Bulk file processing
- Cost-sensitive operations where quality can be slightly lower

---

### 3. Grok Code Fast 1 (github-copilot)

**Context Window**: ~128K tokens (estimated, xAI has not published exact specs)

**Pricing**: Available via GitHub Copilot (exact multipliers not publicly disclosed)

**Benchmarks**:

- **HumanEval**: Estimated 50-60% (xAI has not published official benchmarks)
- **Speed**: Optimized for fast responses
- **Real-time coding**: Designed for rapid iteration

**Strengths**:

- Fast response times
- Real-time context integration
- Growing ecosystem support

**Limitations**:

- Limited public benchmark data
- Newer model with less production feedback
- Context window smaller than Claude/Gemini
- Less transparency on training data and capabilities

**Best For**:

- Experimentation with newer models
- Tasks where speed is critical
- Users preferring xAI ecosystem

**⚠️ Recommendation**: Not recommended as primary agent until more benchmark data available.

---

### 4. Gemini 2.5 Pro (github-copilot)

**Context Window**: 2M tokens (2,000,000 tokens - **largest in comparison**)

**Pricing (via Google AI API)**:

- Input: $1.25/MTok (≤128K), $2.50/MTok (>128K)
- Output: $5/MTok (≤128K), $10/MTok (>128K)

**GitHub Copilot Cost Multiplier**: ~2-3x effective cost vs direct API

**Benchmarks**:

- **HumanEval**: Competitive with GPT-4 level (~85%+ estimated)
- **MMLU**: State-of-the-art (90%+ range)
- **Long-context**: Exceptional performance on 1M+ token tasks
- **Multimodal**: Strong vision capabilities

**Strengths**:

- **2M token context window** - unmatched for large document analysis
- Excellent for processing entire codebases
- Strong reasoning and math capabilities
- Good multilingual support
- Cost-effective for large context tasks

**Limitations**:

- Not as conversational as Claude
- May be overkill for simple tasks
- Rate limits on context window may apply
- Less community feedback on coding-specific tasks vs Claude

**Best For**:

- **Large document analysis** (50K-200K+ tokens) ⭐
- Processing entire Confluence spaces
- Multi-file codebase understanding
- Tasks requiring massive context
- Cost-effective alternative to Sonnet for reasoning tasks

**🎯 Recommendation**: Consider as co-primary agent for document-heavy workflows.

---

### 5. Gemini 3.1 Pro (github-copilot) ⭐ NOW GA

**Context Window**: 2M tokens (2,000,000 tokens - **largest in comparison**)

**Pricing (via Google AI API)**:
- Input: $1.25/MTok (≤128K), $2.50/MTok (>128K)
- Output: $5/MTok (≤128K), $10/MTok (>128K)

**GitHub Copilot Cost Multiplier**: ~2-3x effective cost vs direct API

**Benchmarks**:
- **HumanEval**: ~90% (estimated, improved over 2.5 Pro)
- **MMLU**: State-of-the-art (90%+ range)
- **Long-context**: Exceptional performance on 1M+ token tasks
- **Multimodal**: Enhanced vision capabilities

**Strengths**:
- **2M token context window** - unmatched for large document analysis
- Excellent for processing entire codebases
- Strong reasoning and math capabilities
- Good multilingual support
- Cost-effective for large context tasks
- Now production-ready (out of preview)

**Limitations**:
- Not as conversational as Claude
- May be overkill for simple tasks
- Rate limits on context window may apply

**Best For**:
- **Large document analysis** (50K-2M tokens) ⭐
- Processing entire Confluence spaces
- Multi-file codebase understanding
- Tasks requiring massive context
- Cost-effective alternative to Sonnet for reasoning tasks

**🎯 Recommendation**: Use as document analysis agent for large-context workflows.

---

### 6. GPT-5-mini (github-copilot) ⭐ NEW

**Context Window**: 128K tokens (estimated)

**Pricing (via OpenAI Direct API)**: Estimated competitive with Haiku-class models

**GitHub Copilot Cost Multiplier**: ~2-3x effective cost vs direct API

**Benchmarks**:
- **HumanEval**: Estimated 60-70%
- **MMLU**: Strong performance
- **Speed**: Optimized for low latency
- **Cost**: Most cost-effective in GPT-5 family

**Strengths**:
- Fast response times
- Good balance of capability and cost
- Excellent for simple to moderate complexity tasks
- Strong code generation for common patterns
- Lower token usage than full GPT-5 models

**Limitations**:
- Less capable than Sonnet 4.6 for complex tasks
- May struggle with very complex multi-file refactoring
- Smaller context than Gemini models

**Best For**:
- Quick code snippets and simple tasks ⭐
- Fast iteration cycles
- Cost-sensitive bulk operations
- Simple refactoring tasks
- When speed is prioritized over maximum capability

**🎯 Recommendation**: Use as fast-code agent for simple tasks and quick iterations.

---

### 7. Gemini 3 Pro (github-copilot, preview)

**Status**: ⚠️ **PREVIEW** - Not yet GA

**Context Window**: Expected 2M+ tokens (based on Gemini lineage)

**Pricing**: Not yet announced (preview pricing may differ from GA)

**Benchmarks**: Not yet published

**Strengths**:

- Expected to improve on Gemini 2.5 Pro capabilities
- Likely to maintain large context window
- Early access to next-generation capabilities

**Limitations**:

- **Preview model** - stability and availability not guaranteed
- No published benchmarks
- Pricing unknown
- May have breaking changes before GA
- Limited production use cases

**Best For**:

- Experimentation only
- Non-production workflows
- Testing future capabilities

**❌ Recommendation**: Do not use for production subagents until GA release.

---

### 8. GLM-4.6 "Big Pickle" (OpenCode Zen, free)

**Context Window**: 8K tokens (128K available in other GLM-4 variants)

**Pricing**: **FREE** via OpenCode Zen (with usage limits)

**Model Size**: 9B parameters (open-source)

**Benchmarks**:

- **HumanEval**: 70.1% (better than Llama-3-8B at 62.2%)
- **MMLU**: 74.7% (vs Llama-3-8B at 68.4%)
- **C-Eval**: 77.1% (strong Chinese language performance)
- **GSM8K**: 84.0% (strong math reasoning)
- **MATH**: 30.4%

**Strengths**:

- **Completely free** via OpenCode Zen
- Open-source (Apache 2.0 license)
- Surprisingly strong performance for size
- Good multilingual support (26 languages)
- Can be self-hosted if needed
- Outperforms Llama-3-8B on most benchmarks

**Limitations**:

- **8K context window** (much smaller than competitors)
- Free tier sustainability unknown
- Less capable than frontier models (Sonnet, Gemini)
- May have rate limits on free tier
- Fewer production deployments vs Claude/Gemini

**Best For**:

- **Bulk operations where cost is primary concern** ⭐
- Experimentation with zero cost
- Simple coding tasks that fit in 8K context
- Multi-language support requirements
- Fallback option when rate-limited on paid models

**⚠️ Free Tier Sustainability**: OpenCode Zen's business model is unclear. Free tier may:

- Have undisclosed rate limits
- Be restricted in future
- Have lower SLA guarantees

**🎯 Recommendation**: Use as **cost-optimization tool** for bulk tasks, not as primary agent.

---

## Critical Questions Answered

### Q1: Should Sonnet 4.6 be the primary agent?

**Answer**: **YES** ✅

**Reasoning**:
- Latest model with improvements over 4.5
- Best documented performance on agentic coding tasks
- 2x faster than previous generation
- Excellent at multi-step workflows and tool use
- Strong community feedback and production deployments
- Natural conversational style improves user experience

**Alternative consideration**: Keep 4.5 as fallback if rate-limited.

---

### Q2: Which model(s) best for document-heavy tasks?

**Answer**: **Gemini 3.1 Pro** ⭐ (primary), **Gemini 2.5 Pro** (fallback)

**Reasoning**:
- **2M token context** vs Claude's 200K (10x larger)
- More cost-effective for large contexts ($1.25/MTok vs $3/MTok input)
- Excellent long-context benchmark performance
- Can process entire Confluence spaces in single request
- Strong reasoning for document analysis
- Now production-ready (out of preview)

**Use Sonnet 4.6 when**:
- Document analysis requires conversational interaction
- Iterative refinement needed
- Document size <200K tokens

---

### Q3: Best model for quick tasks and cost optimization?

**Answer**: **GPT-5-mini** ⭐ (primary), **Claude Haiku 4.5** (alternative)

**Reasoning**:
- Fast response times for quick iterations
- Good balance of capability and cost
- More predictable availability than free tiers
- Strong performance on simple to moderate complexity tasks
- Lower latency than full-scale models

**Safe usage pattern**:
```
Primary agent: Claude Sonnet 4.6
Document analysis: Gemini 3.1 Pro
Quick tasks: GPT-5-mini
Fallback: Claude Haiku 4.5
```

**Recommendation**: Use GPT-5-mini for:
- Quick code snippets and generation
- Simple file updates
- Fast iteration cycles
- Cost-sensitive operations with moderate complexity

---

### Q4: Trade-offs with preview models (Gemini 3 Pro)?

**Answer**: **AVOID** ❌ for production subagents

**Trade-offs**:

| Benefit                        | Risk                       |
| ------------------------------ | -------------------------- |
| Early access to capabilities   | Breaking API changes       |
| Potentially better performance | No stability guarantees    |
| Test future features           | Pricing unknown            |
| -                              | Limited documentation      |
| -                              | Unpredictable availability |

**When to use**:

- Personal experimentation only
- Non-production workflows
- A/B testing against stable models

**When NOT to use**:

- Primary coding agent
- Production subagents
- Critical document analysis
- Time-sensitive tasks

---

## Use Case Matrix

### Use Case 1: Primary Coding Agent

**Current**: Claude Sonnet 4.5 ✅

**Evaluation**:

| Model | Suitability | Reason |
|-------|-------------|--------|
| Sonnet 4.5 | ✅✅✅ Excellent | Best agentic coding, 64% HumanEval, multi-step workflows |
| Haiku 4.5 | ✅ Fair | Too limited for complex tasks |
| Grok Code Fast | ✅ Fair | Insufficient benchmark data |
| Gemini 2.5 Pro | ✅✅ Good | Excellent but less conversational |
| Gemini 3 Pro | ❌ Poor | Preview, unstable |
| Big Pickle | ❌ Poor | 8K context too small, free tier risks |

**Recommendation**: **Keep Sonnet 4.5** as primary agent.

---

### Use Case 2: Large Document Analysis (50K-200K tokens)

**Current**: Sonnet 4.5 (assumed)

**Evaluation**:

| Model | Suitability | Cost (100K input) | Reason |
|-------|-------------|-------------------|--------|
| Gemini 2.5 Pro | ✅✅✅ Excellent | $0.125 | 2M context, best $/token ratio |
| Sonnet 4.5 | ✅✅ Good | $0.30 | Great quality, higher cost |
| Haiku 4.5 | ✅ Fair | $0.10 | May miss nuances |
| Grok Code Fast | ❓ Unknown | Unknown | Context window unclear |
| Gemini 3 Pro | ❌ Poor | Unknown | Preview, unstable |
| Big Pickle | ❌ Poor | $0 | 8K context too small |

**Recommendation**: **Switch to Gemini 2.5 Pro** for document analysis subagent.

**Cost savings**: 58% vs Sonnet 4.5 for 100K token inputs.

---

### Use Case 3: Bulk Operations (Processing Many Documents)

**Example**: Update 500 markdown files with consistent changes

**Evaluation**:

| Model | Cost (10M tokens) | Suitability | Reason |
|-------|-------------------|-------------|--------|
| Big Pickle | **$0** (free) | ✅✅✅ Excellent | If tasks fit 8K context |
| Haiku 4.5 | $10 input + $50 output | ✅✅ Good | Fast, affordable |
| Gemini 2.5 Pro | $12.50 in + $50 out | ✅✅ Good | Better reasoning |
| Sonnet 4.5 | $30 in + $150 out | ✅ Fair | Expensive at scale |
| Grok Code Fast | Unknown | ✅ Fair | Pricing unclear |
| Gemini 3 Pro | ❌ Poor | Unknown | Preview, unstable |

**Recommendation**:

1. **First choice**: Big Pickle (if tasks simple and <8K context)
2. **Fallback**: Haiku 4.5 (if Big Pickle rate-limited)
3. **Quality priority**: Gemini 2.5 Pro

**Cost savings**: 100% (Big Pickle) or 67% (Haiku) vs Sonnet 4.5.

---

### Use Case 4: Debug/Refactoring Tasks

**Evaluation**:

| Model | Suitability | Reason |
|-------|-------------|--------|
| Sonnet 4.5 | ✅✅✅ Excellent | Best reasoning, multi-file understanding |
| Gemini 2.5 Pro | ✅✅ Good | Excellent for large codebases |
| Haiku 4.5 | ✅ Fair | Simple refactoring only |
| Grok Code Fast | ✅ Fair | Optimized for speed |
| Big Pickle | ❌ Poor | Limited context |
| Gemini 3 Pro | ❌ Poor | Preview, unstable |

**Recommendation**: **Keep Sonnet 4.5** for complex debugging; use **Gemini 2.5 Pro** when debugging requires >200K context (e.g., large monorepos).

---

### Use Case 5: Creative Ideation

**Evaluation**:

| Model | Suitability | Reason |
|-------|-------------|--------|
| Sonnet 4.5 | ✅✅✅ Excellent | Most conversational, nuanced |
| Gemini 2.5 Pro | ✅✅ Good | Strong reasoning, less creative tone |
| Haiku 4.5 | ✅ Fair | More formulaic |
| Grok Code Fast | ✅ Fair | Less documented creative performance |
| Big Pickle | ✅ Fair | Capable but limited context |
| Gemini 3 Pro | ❌ Poor | Preview, unstable |

**Recommendation**: **Keep Sonnet 4.5** for ideation requiring nuance; **Gemini 2.5 Pro** acceptable for structured brainstorming.

---

## Cost Comparison

### Scenario: Process 1M tokens input + 500K tokens output

| Model              | Input Cost | Output Cost | Total      | Relative Cost |
| ------------------ | ---------- | ----------- | ---------- | ------------- |
| **Big Pickle**     | $0         | $0          | **$0**     | **0%** ⭐     |
| **Haiku 4.5**      | $1.00      | $2.50       | **$3.50**  | **5%**        |
| **Gemini 2.5 Pro** | $1.25      | $2.50       | **$3.75**  | **5%**        |
| **Sonnet 4.5**     | $3.00      | $7.50       | **$10.50** | **15%**       |
| **Grok Code Fast** | Unknown    | Unknown     | Unknown    | Unknown       |
| **Gemini 3 Pro**   | Unknown    | Unknown     | Unknown    | Unknown       |

**Note**: GitHub Copilot adds 2-3x multiplier to all costs above.

### Real-World Cost Example: Document Analysis Workflow

**Task**: Analyze 50 Confluence pages (avg 100K tokens each) = 5M tokens input

| Model              | Direct API Cost | GitHub Copilot Est. |
| ------------------ | --------------- | ------------------- |
| **Big Pickle**     | $0              | N/A (OpenCode Zen)  |
| **Gemini 2.5 Pro** | $6.25           | ~$12-19             |
| **Sonnet 4.5**     | $15.00          | ~$30-45             |

**Savings**: **58-100%** by using Gemini 2.5 Pro or Big Pickle vs Sonnet 4.5.

---

## Speed Comparison

| Model              | Tokens/sec (Estimated) | Latency | Best For               |
| ------------------ | ---------------------- | ------- | ---------------------- |
| **Haiku 4.5**      | ~100-150               | <1s     | Fast iteration         |
| **Grok Code Fast** | ~80-120                | <1s     | Real-time coding       |
| **Sonnet 4.5**     | ~50-80                 | 1-2s    | Balanced speed/quality |
| **Gemini 2.5 Pro** | ~40-70                 | 1-3s    | Large context tasks    |
| **Big Pickle**     | ~60-100                | 1-2s    | Simple tasks           |
| **Gemini 3 Pro**   | Unknown                | Unknown | Preview                |

**Note**: Speed varies by request size and server load. GitHub Copilot may add additional latency.

---

## Recommendations Summary

### Immediate Actions

1. **Upgrade to Claude Sonnet 4.6** as primary coding agent ✅
2. **Add Gemini 3.1 Pro** agent for document analysis (50K+ tokens) ✅
3. **Add GPT-5-mini** agent for quick tasks and cost optimization ✅
4. **Keep Claude Sonnet 4.5** as fallback for rate limiting ✅
5. **Keep Claude Haiku 4.5** as additional fallback ✅
6. **Avoid Gemini 3 Pro** until GA release ⏸️

### Updated Subagent Architecture

```yaml
agents:
  build:
    model: claude-sonnet-4.6
    provider: github-copilot
    use_cases:
      - Complex coding tasks
      - Multi-file refactoring
      - General programming
      - Creative ideation

  plan:
    model: claude-sonnet-4.6
    provider: github-copilot
    use_cases:
      - Analysis & planning without changes
      - Architecture review
      - Code review and suggestions

  doc-analyzer:
    model: gemini-3.1-pro # UPDATED
    provider: github-copilot
    use_cases:
      - Large document analysis (>50K tokens)
      - Confluence page processing
      - Entire codebase review
      - Multi-file context understanding

  fast-code:
    model: gpt-5-mini # NEW
    provider: github-copilot
    use_cases:
      - Quick code snippets
      - Simple transformations
      - Fast iteration cycles
      - Cost-sensitive simple operations
    fallback: claude-haiku-4.5
```

### Cost Optimization Strategy

1. **Route by complexity**:
   - Complex reasoning → Sonnet 4.6
   - Large context → Gemini 3.1 Pro
   - Simple/quick tasks → GPT-5-mini
   - Fallback → Haiku 4.5 or Sonnet 4.5

2. **Monitor rate limits**:
   - Track GitHub Copilot usage quotas
   - Have multiple fallback options configured
   - Review monthly usage patterns

3. **Document analysis optimization**:
   - Use Gemini 3.1 Pro for >50K tokens (58% cost savings)
   - Use Sonnet 4.6 for <50K tokens (better conversational quality)

---

## Sources & Further Reading

### Official Documentation

- [Claude 3.5 Sonnet Announcement](https://www.anthropic.com/news/claude-3-5-sonnet) - Anthropic, June 2024
- [Claude Pricing](https://www.anthropic.com/pricing) - Anthropic
- [Gemini Models Overview](https://ai.google.dev/gemini-api/docs/models/gemini) - Google
- [GLM-4 GitHub](https://github.com/THUDM/GLM-4) - THUDM
- [GLM-4-9B Model Card](https://huggingface.co/THUDM/glm-4-9b) - Hugging Face

### Benchmarks

- **HumanEval**: Coding capability benchmark
- **MMLU**: Multitask language understanding
- **GPQA**: Graduate-level reasoning
- **SWE-bench**: Real-world software engineering tasks
- **GSM8K**: Math reasoning
- **C-Eval**: Chinese language benchmark

### Community Resources

- [Artificial Analysis](https://artificialanalysis.ai/) - Real-time model comparisons
- [LM Arena Leaderboard](https://huggingface.co/spaces/lmarena-ai/chatbot-arena-leaderboard) - Community model rankings
- [OpenCode Documentation](https://opencode.ai/docs) - OpenCode Zen details

### GitHub Copilot Pricing

- GitHub Copilot Individual: $10/month
- GitHub Copilot Business: $19/month
- Effective cost multiplier vs direct API: 2-3x (estimated)

---

## Changelog

- **2026-03-10**: Major update for new model releases
  - **Added**: Claude Sonnet 4.6 (primary agent upgrade)
  - **Added**: Gemini 3.1 Pro (now GA, replaces 2.5 Pro for documents)
  - **Added**: GPT-5-mini (fast code generation)
  - **Updated**: Recommendations to use Sonnet 4.6 as primary
  - **Updated**: Architecture to include doc-analyzer and fast-code agents
  - Removed dependency on free-tier models for production use
  
- **2024-12-20**: Initial comparison created
  - Added 6 models: Claude Sonnet 4.5, Claude Haiku 4.5, Grok Code Fast 1, Gemini 2.5 Pro, Gemini 3 Pro, GLM-4.6 Big Pickle
  - Evaluated for coding, document analysis, bulk operations, debugging, creative tasks
  - Recommended keeping Sonnet 4.5 as primary, adding Gemini 2.5 Pro for documents, Big Pickle for bulk ops

---

## Notes

- **GitHub Copilot access**: Pricing details for individual models via Copilot are not publicly disclosed. Estimates based on direct API pricing with 2-3x multiplier.
- **Rate limits**: All models via GitHub Copilot may have rate limits based on subscription tier.
- **Context window practical limits**: Advertised context windows (e.g., 2M for Gemini) may have practical limits or additional costs.
- **Benchmark variability**: Real-world performance may vary from published benchmarks based on specific use cases.
- **Free tier changes**: OpenCode Zen and other free tiers may change policies without notice.

---

**Prepared by**: OpenCode Analysis  
**Date**: March 10, 2026  
**Version**: 2.0
