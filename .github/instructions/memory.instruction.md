---
applyTo: "**"
---

# User Memory

## User Preferences

- Programming languages: [Nix, shell, Lua, TypeScript]
- Code style preferences: [2-space indentation, Nix formatting via nixfmt, kebab-case files]
- Development environment: [macOS, Nix/nix-darwin]
- Communication style: [concise, technical]

## Project Context

- Current project type: Nix/nix-darwin configuration repository for macOS
- Tech stack: Nix, home-manager, shell scripts, Lua (Neovim)
- Key requirements: Declarative configuration, no secrets committed

## Coding Patterns

- Preferred patterns: modular Nix files, explicit imports, use of `inherit`

## Context7 Research History

- **LazyVim neotest**: test.core extra already enabled in lazyvim.json, provides neotest with nvim-nio dependency
- **Custom Jest wrappers**: Some projects use wrappers around Jest (e.g., sku, skuba); command is `wrapper test` not `jest`; uses custom config; neotest-jest works via `jestCommand = "yarn wrapper test"`
- **neotest-jest test file patterns**: Matches `*.test.[jt]sx?` and `*.spec.[jt]sx?` filename patterns (prioritizes filename over directory structure)

## Conversation History

- Created new prompt: home-manager/opencode/prompts/beast-mode-3.1-context7-with-memory.md (in_progress)

## Notes

- **Neovim setup**: Using LazyVim with many extras, Neovim managed via Stow (not Nix)
- **LazyVim pattern**: Enable extra in lazyvim.json, customize via lua/plugins/{name}.lua with opts overrides
- **Always check lazyvim.json**: LazyVim extras provide base configurations; custom plugins override/extend them
