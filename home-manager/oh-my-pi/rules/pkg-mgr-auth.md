---
description: pnpm/npm/yarn need `op run` for @seek-scoped packages (private registry auth)
condition:
  - "(pnpm|npm|yarn)\\s+(install|add|publish|pack|ci)"
interruptMode: tool-only
scope:
  - "tool:bash"
---

# pnpm/npm/yarn must use `op run` for @seek packages

pnpm, npm, and yarn are wrapped with `op run --env-file=...` in the shell config to provide registry auth tokens for `@seek`-scoped packages.

When running package manager commands, especially those that might access `@seek`-scoped packages:

```bash
# Use op run prefix:
op run --env-file="$HOME/.config/op-env/npm-env" -- pnpm install

# Or for simple installs that don't need @seek packages, direct is fine:
pnpm install  # OK if no @seek packages involved
```

Commands that definitely need `op run`:
- `pnpm publish`, `npm publish` — auth required
- `pnpm install`, `npm install` — if package.json has `@seek/*` dependencies
- `pnpm pack` — if it resolves @seek packages
