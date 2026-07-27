---
description: Always use the herdr skill for terminal and multiplexer operations
alwaysApply: true
---

# Herdr-first terminal workflow

The user works almost entirely inside Herdr (terminal multiplexer). You MUST read `skill://herdr` before your first terminal/multiplexer action in every session and follow it for pane, tab, workspace, and agent-coordination operations.

- If `HERDR_ENV=1` is set, you are inside a Herdr-managed pane — use the `herdr` CLI per the skill (inspect workspaces/tabs/panes, split panes without stealing focus, read pane output, wait on processes or sibling agents).
- If `HERDR_ENV` is NOT set, say so and do not attempt Herdr control (skill safety rule).
- Prefer herdr CLI operations over suggesting manual tmux/zellij-style workflows; zellij is no longer part of this setup.
