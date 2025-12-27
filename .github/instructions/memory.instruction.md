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
- **diffview.nvim** (Dec 2025): De facto standard for 3-way merge conflicts in Neovim; provides IntelliJ IDEA-level merge tool experience with 3-way/4-way diff layouts, conflict navigation (`[x`/`]x`), and resolution commands (`<leader>co/ct/cb/ca/cn`); integrates with LazyVim git keybindings under `<leader>g` prefix

## Known Issues

### Neovim Stability (Dec 2025)

**Issue**: Neovim crashes intermittently with zombie processes
**Root Causes**:

- Embedded nvim processes (`--embed` flag) not cleaned up properly
- Language server processes (copilot, yaml-ls, bash-ls) persist after crashes
- TUI race conditions on abrupt exits
- dropbar.nvim loaded eagerly causing startup issues
- snacks.nvim image support may cause crashes on non-kitty terminals

**Solutions Applied**:

1. Created cleanup script: `scripts/nvim-cleanup.sh` (run periodically)
2. Changed dropbar.nvim from `lazy=false` to `event="VeryLazy"`
3. Added filetype exclusions for dropbar to prevent crashes
4. Disabled snacks.nvim image support by default
5. Copilot authentication errors (non-critical, can be ignored)

**Monitoring**:

- Check `ps aux | grep nvim` for zombie processes
- Review logs: `~/.local/state/nvim/lsp.log`, `~/.local/state/nvim/log`
- Run cleanup if >10 nvim processes exist

## Conversation History

- Optimized menatey-rima-mode-1.0.md for context efficiency (v4):
  - **FIXED**: Corrected subagent delegation mechanism - uses `task` tool with `subagent_type` parameter (NOT @mention)
  - Added explicit delegation triggers with model info (debug-premium, test-gen, docs-writer, etc.)
  - File size: 103 lines, 4KB (~1100 tokens)
  - Multi-model optimized (Claude/Gemini/GLM/Haiku)
  - Created test project in /tmp/opencode-subagent-test for validation
  - ✅ **REBUILT**: darwin-rebuild completed, new prompt now active (Option C)

**Key finding**: OpenCode subagents are invoked via the `task` tool, not automatic delegation or @mention syntax. Primary agent must explicitly call the task tool with subagent_type parameter.

**Important**: Previous 0/4 test results were invalid - darwin-rebuild had not been run yet. First valid testing starts now.

- **diffview.nvim integration** (Dec 25, 2024):
  - Added professional 3-way merge conflict resolution to Neovim (LazyVim setup)
  - Replaces need for IntelliJ IDEA for complex merge conflicts
  - Key commands: `<leader>gv` (open diffview), `<leader>gh` (file history), `<leader>gm` (PR diff)
  - Conflict resolution: `<leader>co/ct/cb/ca/cn` for OURS/THEIRS/BASE/ALL/NONE
  - Navigation: `[x`/`]x` for prev/next conflict, `g<C-x>` to cycle layouts
  - File: `nvim/lua/plugins/diffview.lua`

## Notes

- **Neovim setup**: Using LazyVim with many extras, Neovim managed via Stow (not Nix)
- **LazyVim pattern**: Enable extra in lazyvim.json, customize via lua/plugins/{name}.lua with opts overrides
- **Always check lazyvim.json**: LazyVim extras provide base configurations; custom plugins override/extend them
