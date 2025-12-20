# OpenCode Agents Cheat Sheet (GitHub Copilot Models)

Design focused on: quota conservation, fast iteration, deep reasoning only when needed, and clear task routing for fullstack + platform engineering workflows.

> Adjust model version suffixes (dates) to match `/models` output. Run `/models` to confirm exact IDs before finalizing.

## Model Allocation (GitHub Copilot Enabled)

| Tier                      | Model (provider/id)                    | Use Primarily For                                                    | Escalate When                                           | Avoid Using For                         |
| ------------------------- | -------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------- | --------------------------------------- |
| Premium (top)             | `anthropic/claude-sonnet-4-5-20250514` | Hard debugging (race/deadlock), deep architecture, complex refactors | Cross-service causal analysis; ambiguous business logic | Boilerplate, trivial doc edits          |
| Premium                   | `anthropic/claude-sonnet-4-20250514`   | Spec distillation, architecture consolidation, policy logic          | Need precision but not max reasoning                    | Highly creative divergence              |
| Premium (stretch)         | `anthropic/claude-sonnet-3-5-2025XXXX` | Medium refactors, code reviews, risk surfacing                       | Repeated gaps from `gpt-4o`                             | Heavy multimodal tasks                  |
| Premium (creative)        | `openai/gpt-5`                         | Design brainstorming, multiple solution patterns                     | Need divergent options before converging                | Deterministic patch planning            |
| Premium (multimodal)      | `google/gemini-3-pro-preview`          | UI screenshot/layout diagnosis, large context ingestion              | Visual diff analysis, whole-module summarization        | Simple text-only clarifications         |
| Workhorse                 | `openai/gpt-4o`                        | Daily coding, docs drafts, simple bugs, test generation              | Stalls after 2 focused attempts                         | Concurrency or subtle state bugs        |
| Fast                      | `openai/gpt-4.1`                       | Rapid iteration, boilerplate scaffolding                             | Need more context fidelity                              | Deep reasoning or long summaries        |
| Ultra-light               | `openai/gpt-5-mini`                    | Lookups, quick routing decisions, trivial Q&A                        | Need structured analysis                                | Anything requiring multi-step reasoning |

### Escalation Signals

- Multiple modules intertwined, unclear state transitions.
- Performance regression without obvious hotspot.
- Security/privacy implications or data integrity risk.
- Concurrency, race, deadlock, intermittent failure.
- Requirement ambiguity causing conflicting interpretations.
- Large refactor (>4 modules) with hidden coupling.

## Primary Agents (JSON Config)

Add/adjust in `opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": {
      "description": "Primary dev agent with full tool access",
      "mode": "primary",
      "model": "openai/gpt-4o",
      "temperature": 0.3,
      "tools": { "write": true, "edit": true, "bash": true },
    },
    "plan": {
      "description": "Analysis & planning without direct changes",
      "mode": "primary",
      "model": "openai/gpt-4o",
      "temperature": 0.15,
      "tools": { "write": false, "edit": false, "bash": false },
    },
  },
}
```

## Subagent Markdown Definitions

Place these in `.opencode/agent/` (project) or `~/.config/opencode/agent/` (global). Filenames become agent names (invoke via `@agentname`).

### 1. `debug.md`

```markdown
---
description: Investigates and diagnoses complex bugs
mode: subagent
model: github-copilot/claude-sonnet-4.5
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

### 2. `refactor-review.md`

```markdown
---
description: Reviews code and proposes safe phased refactor plans
mode: subagent
model: github-copilot/claude-sonnet-4.5
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
model: github-copilot/claude-sonnet-4.5
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
model: github-copilot/claude-haiku-4.5
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

### 5. `test-gen.md`

```markdown
---
description: Generates comprehensive test matrices
mode: subagent
model: github-copilot/claude-sonnet-4.5
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
model: github-copilot/gemini-3-pro-preview
temperature: 0.7
tools:
  write: false
  edit: false
---

Produce 3–5 distinct approaches.
For each: Summary, Pros, Cons, Complexity, Migration Path, Risks.
Conclude with comparative recommendation & decision criteria.
```

### 7. `multimodal-ui.md`

```markdown
---
description: Analyzes UI screenshots and layout/style issues
mode: subagent
model: github-copilot/gemini-3-pro-preview
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

### 8. `infra-platform.md`

```markdown
---
description: Assists with infra & platform troubleshooting
mode: subagent
model: github-copilot/claude-sonnet-4.5
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
model: github-copilot/claude-haiku-4.5
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

## Quota Conservation Pattern

1. Start cheap (`gpt-4o`, `gpt-4.1`).
2. After 2 unsuccessful attempts or escalation signals → premium (`sonnet-*`).
3. After premium reasoning, implementation & test writing revert to workhorse models.
4. Use `gemini-3-pro-preview` only with screenshots or >150KB context to summarize.
5. Use `gpt-5-mini` to decide escalation when uncertain.

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
model: opencode/big-pickle
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

## Actual Subagent Configuration

The repository currently has 10 subagents configured in `home-manager/opencode/agent/`:

| Subagent | Model | Temp | Tools | Use Case |
|----------|-------|------|-------|----------|
| `debug` | claude-sonnet-4.5 | 0.2 | bash (git restricted) | Complex bug investigation |
| `refactor-review` | claude-sonnet-4.5 | 0.15 | read-only | Code review and refactor planning |
| `spec-distiller` | claude-sonnet-4.5 | 0.2 | read-only | Requirements refinement |
| `docs-writer` | claude-haiku-4.5 | 0.3 | write, edit | Technical documentation |
| `test-gen` | claude-sonnet-4.5 | 0.2 | read-only | Test matrix generation |
| `creative-ideation` | gemini-3-pro-preview | 0.7 | read-only | Architecture brainstorming |
| `multimodal-ui` | gemini-3-pro-preview | 0.25 | read-only | UI/screenshot analysis |
| `infra-platform` | claude-sonnet-4.5 | 0.2 | bash (kubectl/docker restricted) | Infrastructure troubleshooting |
| `quota-sentry` | claude-haiku-4.5 | 0.1 | read-only | Cost escalation decisions |
| `doc-analyser` | opencode/big-pickle | 0.1 | read-only | Large document analysis |

**Note**: All GitHub Copilot models use `github-copilot/` prefix in actual config.

## Next Steps

1. Subagent definitions are already in `home-manager/opencode/agent/`.
2. Run `/models` in OpenCode to verify available model IDs.
3. Test subagents with `@debug`, `@spec-distiller`, etc.
4. Monitor usage and adjust model assignments if needed.

---

Feel free to request a trimmed version (fewer agents) or an agent merger strategy if this feels too large.
