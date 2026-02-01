# OpenCode Agents Cheat Sheet (OpenCode Models)

Design focused on: cost efficiency, fast iteration, deep reasoning only when needed, and clear task routing for fullstack + platform engineering workflows.

> Run `/models` in OpenCode to confirm available model IDs. Model availability may vary.

## Model Allocation (OpenCode Provider)

| Tier              | Model (provider/id)         | Use Primarily For                                              | Escalate When                                    | Avoid Using For                  |
| ----------------- | --------------------------- | -------------------------------------------------------------- | ------------------------------------------------ | -------------------------------- |
| Primary           | `opencode/kimi-k2.5-free`   | Daily coding, debugging, docs, tests, architecture, refactoring | Complex multi-step reasoning beyond context      | Simple lookups, trivial Q&A      |
| Large Context     | `opencode/big-pickle`       | Large document analysis, bulk operations, whole-module review   | Need reasoning + large context combined          | Quick tasks (overkill)           |
| Fast/Light        | (provider-specific)         | Rapid iteration, boilerplate, quick routing                    | Need deeper analysis or precision                | Complex reasoning tasks          |

### Escalation Signals

- Multiple modules intertwined, unclear state transitions.
- Performance regression without obvious hotspot.
- Security/privacy implications or data integrity risk.
- Concurrency, race, deadlock, intermittent failure.
- Requirement ambiguity causing conflicting interpretations.
- Large refactor (>4 modules) with hidden coupling.

## Primary Agents (Nix Config)

Configure in `home-manager/opencode.nix` using the `programs.opencode` module. See the actual config file for current settings.

## Subagent Markdown Definitions

Place these in `.opencode/agent/` (project) or `~/.config/opencode/agent/` (global). Filenames become agent names (invoke via `@agentname`).

### 1. `debug.md`

```markdown
---
description: Investigates and diagnoses complex bugs
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.2
tools:
  bash: true
  write: false
  edit: false
permission:
  bash:
    "git *": ask
    "*": allow
---

You are a senior debugging engineer

Process:

1. Restate symptoms & scope.
2. Form ranked hypotheses with evidence tags.
3. Request missing artifacts explicitly.
4. Provide minimal fix & regression test matrix.

Output sections: Summary, Hypotheses (ranked), Evidence Needed, Recommended Fix, Test Matrix.
```

**Note:** Uses `kimi-k2.5-free` for cost-effective deep debugging without Copilot quota consumption.

### 2. `refactor-review.md`

```markdown
---
description: Reviews code and proposes safe phased refactor plans
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.15
tools:
  write: false
  edit: false
  bash: false
---

Act as a refactor strategist.
Steps:
- Identify coupling & pain points.
- Propose phased plan (phase, rationale, risk, rollback).
- Suggest invariants & acceptance tests.
Return sections: Hotspots, Plan (Phases), Risks, Tests.
```

### 3. `spec-distiller.md`

```markdown
---
description: Converts vague requirements into actionable specs
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.2
tools:
  write: false
  edit: false
---

Transform raw requirement into:
- Assumptions
- Clarifying Questions
- Acceptance Criteria
- Edge Cases
- Non-functional Requirements
Return concise structured lists.
```

### 4. `docs-writer.md`

```markdown
---
description: Drafts and refines technical documentation
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.3
tools:
  write: true
  edit: true
  bash: false
---

Technical writer mode (Mini Beast). Rephrase user goal first. Produce clear docs:
Sections: Overview, Quickstart, Configuration, Examples, Pitfalls, Troubleshooting.
Ask for missing context before guessing.
Maintain consistent terminology.
Follow Mini Beast workflow: clarify goal, outline sections, iterate succinctly; never over-explain changes.
```

**Note:** `kimi-k2.5-free` at temp 0.3 provides good balance of creativity and consistency for documentation.

### 5. `test-gen.md`

```markdown
---
description: Generates comprehensive test matrices
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.2
tools:
  write: false
  edit: false
---

Rephrase goal first (Mini Beast). Generate categorized tests:
- Happy Path
- Failure Modes
- Edge Boundaries
- Concurrency (if applicable)
- Performance (if relevant)
Return table: Case | Purpose | Notes.
Add summary of coverage gaps.
Follow Mini Beast workflow: clarify, plan silently, output concise matrix.
```

### 6. `creative-ideation.md`

```markdown
---
description: Brainstorms multiple architecture or design approaches
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.5
tools:
  write: false
  edit: false
---

Produce 3–5 distinct approaches.
For each: Summary, Pros, Cons, Complexity, Migration Path, Risks.
Conclude with comparative recommendation & decision criteria.
```

**Note:** Temperature 0.5 with `kimi-k2.5-free` provides balanced creative divergence without excessive variation. Kimi's native creativity at 0.7 was producing overly divergent outputs.

### 7. `multimodal-ui.md`

```markdown
---
description: Analyzes UI screenshots and layout/style issues
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.25
tools:
  write: false
  edit: false
  bash: false
---

Given screenshot + component/style snippets:
Identify discrepancies (layout, state, styling, data).
Prioritize root causes.
Output: Issues, Suspected Causes, Fix Steps, Suggested Tests.
Request missing snippets if incomplete.
```

**Note:** `kimi-k2.5-free` supports multimodal inputs. Test with actual screenshots to verify analysis quality.

### 8. `infra-platform.md`

```markdown
---
description: Assists with infra & platform troubleshooting
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.2
tools:
  bash: true
  write: false
  edit: false
permission:
  bash:
    "kubectl *": ask
    "docker *": ask
    "*": allow
---

Platform engineer lens (Mini Beast: rephrase goal first):
Summarize environment, logs, config.
Provide investigative next steps BEFORE prescribing large changes.
Follow Mini Beast workflow: clarify, investigate, plan internally, act incrementally.
Output: Environment Summary, Suspicions, Next Checks, Minimal Fix, Hardening Suggestions.
```

### 9. `quota-sentry.md`

```markdown
---
description: Advises whether to escalate to premium model
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.1
tools:
  write: false
  edit: false
---

Mini Beast: rephrase user task succinctly. Given task summary + attempted steps:
Decide: stay / escalate / de-escalate.
Return: Decision, Rationale, Recommended Agent.
Follow Mini Beast workflow; keep output terse (3 sentences max).
```

**Note:** With all agents now on `kimi-k2.5-free`, this agent primarily helps decide when to switch to other providers (GitHub Copilot) if configured.

## Usage Flow Examples

1. Vague ticket → `@spec-distiller` → produce spec → implement in `build`.
2. Routine feature coding → stay in `build` (`gpt-4o`).
3. Complex bug emerges → `@debug` (premium). After plan, implement fix back in `build`.
4. Large refactor planning → `@refactor-review` → phased plan & risks.
5. Architecture brainstorming → `@creative-ideation` then refine chosen path with `@spec-distiller`.
6. UI layout issue with screenshot → `@multimodal-ui` then apply fixes in `build`.
7. Generate tests for new module → `@test-gen`.
8. Platform incident → start `@infra-platform`; escalate to `@debug` if deeper causal chain.
9. Unsure about escalation → `@quota-sentry`.

## Prompt Snippets

Use these when invoking agents (paste after @ mention):

- Debug: "Symptoms: ... Logs: ... Scope: files A,B,C. Goal: restore X."
- Spec: "Raw requirement: ... Constraints: ... Stakeholders: ..."
- Refactor: "Target: reduce coupling in module X. Pain points: ..."
- Ideation: "Need design for feature Y. Constraints: scale to N users, low latency."
- UI: "Screenshot attached. Components: Header.tsx, Layout.css. Expected: ... Got: ..."
- Infra: "Cluster issue: high CPU in svc A. Metrics excerpt: ... Config: ..."

## Temperature Guidelines

- 0.1–0.2: Deterministic analysis (spec, refactor, deep debug)
- 0.25–0.35: Balanced generation (tests, infra, docs)
- 0.6+: Divergent ideation (architecture alternatives)

## Cost Optimization Pattern

With all agents on `opencode/kimi-k2.5-free` (free tier):

1. **Default**: All work happens on `kimi-k2.5-free` at no cost
2. **Escalation to premium**: If configured, escalate to GitHub Copilot models for:
   - Tasks failing after 2 attempts on kimi
   - Complex reasoning beyond kimi's context limits
   - Need for specific model capabilities (e.g., Claude's reasoning)
3. **De-escalation**: Return to `kimi-k2.5-free` for implementation after premium planning
4. **Monitor rate limits**: Free tiers may have rate limits; adjust if you hit throttling

## Validation Loop

- Premium output → `@test-gen` for coverage.
- Refactor plan → replay with `@refactor-review` after first phase implemented.
- Debug fix → ask `@debug` for regression test set before merge.

## Adjusting Models

If Copilot provider exposes different IDs (e.g. without date suffix) replace model strings accordingly. Example replacements:

- `anthropic/claude-sonnet-4-5` (if date-less)
- `openai/gpt-4o` (stable)
- `openai/gpt-4.1` (fast iteration)
- `openai/gpt-5-mini` (lightweight)
- `google/gemini-3-pro-preview`

### 10. `doc-analyser.md`

```markdown
---
description: Analyzes large documents and performs bulk operations
mode: subagent
model: opencode/kimi-k2.5-free
temperature: 0.1
tools:
  bash: false
  write: false
  edit: false
---

You are a document analysis specialist optimized for large-context processing.

Process:

1. Read and comprehend large documents or multiple files
2. Identify patterns, inconsistencies, or required transformations
3. Provide structured analysis with specific line/section references
4. Recommend batch operations for consistency

Output format: Summary, Key Findings (with references), Recommended Actions, Bulk Operation Scripts (if applicable).
```

**Note:** Currently uses `kimi-k2.5-free`. Consider `opencode/big-pickle` for very large context windows if available.

## Actual Subagent Configuration

The repository currently has 10 subagents configured in `home-manager/opencode/agent/`:

| Subagent | Model | Temp | Tools | Use Case |
|----------|-------|------|-------|----------|
| `debug` | opencode/kimi-k2.5-free | 0.2 | bash (git restricted) | Complex bug investigation |
| `refactor-review` | opencode/kimi-k2.5-free | 0.15 | read-only | Code review and refactor planning |
| `spec-distiller` | opencode/kimi-k2.5-free | 0.2 | read-only | Requirements refinement |
| `docs-writer` | opencode/kimi-k2.5-free | 0.3 | write, edit | Technical documentation |
| `test-gen` | opencode/kimi-k2.5-free | 0.2 | read-only | Test matrix generation |
| `creative-ideation` | opencode/kimi-k2.5-free | 0.7 | read-only | Architecture brainstorming |
| `multimodal-ui` | opencode/kimi-k2.5-free | 0.25 | read-only | UI/screenshot analysis |
| `infra-platform` | opencode/kimi-k2.5-free | 0.2 | bash (kubectl/docker restricted) | Infrastructure troubleshooting |
| `quota-sentry` | opencode/kimi-k2.5-free | 0.1 | read-only | Cost escalation decisions |
| `doc-analyser` | opencode/kimi-k2.5-free | 0.1 | read-only | Large document analysis |

**Note**: All agents now use `opencode/kimi-k2.5-free` for cost-effective operation. GitHub Copilot provider config is retained for optional premium escalation.

## Next Steps

1. Agents are configured in `home-manager/opencode.nix` via the Nix module.
2. Agent definitions (markdown) are in `home-manager/opencode/agent/`.
3. Run `/models` in OpenCode to verify available model IDs.
4. Test subagents with `@debug`, `@spec-distiller`, etc.
5. Monitor usage and adjust model assignments if needed.

---

Feel free to request a trimmed version (fewer agents) or an agent merger strategy if this feels too large.
