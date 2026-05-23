---
description: Prefer /plan for risky operations before making changes
condition:
  - "(?i)(edit|write|bash).*\\b(3|three|several|multiple)\\b.*files?"
  - "(?i)(git reset|git push.*--force|rm\\s+-rf)"
  - "(?i)(refactor|restructur|rewrite)"
interruptMode: always
scope:
  - "tool:bash"
  - "tool:edit"
  - "tool:write"
---

# Guardrails — prefer plan mode for risky operations

Before editing 3+ files, refactoring, restructuring, or running destructive commands (rm -rf, git push --force, git reset), use /plan first.

During planning: read-only tools only (read, search, find). No writes, no edits.
After plan approval: implement step by step, validate at each step.

If the task is simple (single-file edit, straightforward question), direct execution is fine.
