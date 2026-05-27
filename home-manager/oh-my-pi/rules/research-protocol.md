---
description: Priority ladder for research — Context7 first, then web search, then fetch, then bash
condition: []
interruptMode: tool-only
scope:
  - "tool:bash"
  - "tool:search"
  - "tool:web_search"
---

# Research Priority Ladder

Your knowledge may be outdated. Use this priority order when researching (do not skip levels):

1. **context7** — Library/framework/package documentation (MCP server)
2. **web_search** — Semantic web search for docs, blogs, troubleshooting, general knowledge
3. **read URL** — Read user-provided URLs and referenced links
4. **bash + curl** — Fallback for simple URL fetches when others are insufficient
5. **Follow recursively** — Read referenced documentation until you have sufficient information

## Efficiency principle

- Act directly when the path is clear
- Use parallel tool calls when operations are independent
- Use `ask` when the request is ambiguous rather than guessing
