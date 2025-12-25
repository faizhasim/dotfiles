# Neovim Auto-Format Control

## Quick Reference

### Commands Available

| Command | Description | Example |
|---------|-------------|---------|
| `:FormatDisable` | Disable auto-format **globally** (all buffers) | `:FormatDisable` |
| `:FormatDisable!` | Disable auto-format for **current buffer only** | `:FormatDisable!` |
| `:FormatEnable` | Re-enable auto-format (clears both global and buffer) | `:FormatEnable` |
| `:FormatStatus` | Check current formatting status | `:FormatStatus` |

### Usage Examples

**Disable formatting for a specific markdown file:**
```vim
:FormatDisable!
" Edit your markdown without auto-formatting
" When done: :FormatEnable
```

**Temporarily disable all formatting:**
```vim
:FormatDisable
" Work on multiple files
" When done: :FormatEnable
```

**Check if formatting is enabled:**
```vim
:FormatStatus
```

### Alternative Methods

#### Per-Line Ignore (In Markdown)
```markdown
<!-- prettier-ignore -->
This   line   preserves    spacing!

<!-- prettier-ignore-start -->
Multiple lines
  with   custom    formatting
will be preserved!
<!-- prettier-ignore-end -->
```

#### Per-File Ignore (`.prettierignore`)
Add to `.prettierignore` in project root:
```gitignore
# Ignore specific files
docs/draft.md

# Ignore directory
notes/**/*.md
```

## Implementation Details

- **Files modified:**
  - `nvim/lua/plugins/conform.lua` - Configures conform.nvim to check disable flags
  - `nvim/lua/config/autocmds.lua` - Adds user commands

- **How it works:**
  - Commands set `vim.g.disable_autoformat` (global) or `vim.b.disable_autoformat` (buffer-local)
  - conform.nvim checks these variables before formatting on save

- **Restart required:**
  - Restart Neovim or run `:Lazy reload conform.nvim` for changes to take effect
