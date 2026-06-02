---
description: Priority ladder for research — Context7 first, then web search, then fetch, then bash
alwaysApply: true
---

# Research Priority Ladder

Your training data may be outdated. **You MUST use context7 before writing any code or answer involving external libraries, frameworks, APIs, SDKs, CLI tools, or cloud services.**

## Priority order (do not skip levels)

1. **context7** (MCP server) — Fetch current library/framework/package documentation, API signatures, version numbers, configuration syntax
2. **web_search** — Semantic web search for docs, blogs, troubleshooting, general knowledge
3. **read URL** — Read user-provided URLs and referenced links
4. **bash + curl** — Fallback for simple URL fetches when others are insufficient
5. **Follow recursively** — Read referenced documentation until you have sufficient information

## When to use context7

- **Always** before using a library/API call you haven't verified this session
- **Always** when the user asks about package versions, deprecation status, or migration guides
- **Always** when writing configuration for tools like Terraform, Docker, Kubernetes, CI/CD
- **Always** when the user provides documentation URLs — read them in parallel with your research

## Efficiency principles

- Act directly when the path is clear (e.g. standard library, well-known algorithms)
- Use parallel tool calls when operations are independent
- Use `ask` when the request is ambiguous rather than guessing
