# Diffview.nvim Quick Reference

Professional 3-way merge conflict resolution and git diff tooling for Neovim (LazyVim).

## 🚀 Quick Start

### Opening Diffviews

| Command | Description |
|---------|-------------|
| `<leader>gv` | Open diffview for current changes (vs index) |
| `<leader>gV` | Diffview vs HEAD |
| `<leader>gh` | File history for current file (detailed) |
| `<leader>gH` | Full repository history |
| `<leader>gm` | PR-style diff (origin/main...HEAD) |
| `<leader>gq` | Close diffview |

### During Merge Conflicts

When you have merge conflicts, opening a file will automatically show a **3-way diff**:

```
┌─────────────┬─────────────┬─────────────┐
│    OURS     │   WORKING   │   THEIRS    │
│ (your code) │  (result)   │  (incoming) │
└─────────────┴─────────────┴─────────────┘
```

## ⌨️ Conflict Resolution

### Navigate Conflicts

| Key | Action |
|-----|--------|
| `[x` | Previous conflict |
| `]x` | Next conflict |

### Resolve Single Conflict (at cursor)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>co` | Choose **OURS** | Keep your version |
| `<leader>ct` | Choose **THEIRS** | Accept incoming changes |
| `<leader>cb` | Choose **BASE** | Use common ancestor |
| `<leader>ca` | Choose **ALL** | Keep both versions |
| `<leader>cn` | Choose **NONE** | Delete conflict region |

### Resolve Entire File

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>cO` | Choose **OURS** (whole file) | Keep all your changes |
| `<leader>cT` | Choose **THEIRS** (whole file) | Accept all incoming changes |
| `<leader>cB` | Choose **BASE** (whole file) | Revert to common ancestor |
| `<leader>cA` | Choose **ALL** (whole file) | Keep both versions everywhere |
| `<leader>cN` | Choose **NONE** (whole file) | Delete all conflicts |

## 📁 File Panel

| Key | Action |
|-----|--------|
| `<tab>` / `<s-tab>` | Next/previous file |
| `<cr>` / `o` / `l` | Open file diff |
| `j` / `k` | Navigate entries |
| `<leader>e` | Focus file panel |
| `<leader>b` | Toggle file panel |
| `zo` / `zc` | Open/close fold |
| `zR` / `zM` | Open/close all folds |

### Staging (when diffing vs index)

| Key | Action |
|-----|--------|
| `-` / `s` | Stage/unstage file |
| `S` | Stage all |
| `U` | Unstage all |
| `X` | Restore file |

## 🎨 Diff Operations

### 3-Way Diff

| Key | Action |
|-----|--------|
| `2do` | Get hunk from **OURS** |
| `3do` | Get hunk from **THEIRS** |

### 4-Way Diff (includes BASE column)

| Key | Action |
|-----|--------|
| `1do` | Get hunk from **BASE** |
| `2do` | Get hunk from **OURS** |
| `3do` | Get hunk from **THEIRS** |

## 🔄 Layout & Navigation

| Key | Action |
|-----|--------|
| `g<C-x>` | Cycle layouts (2-way, 3-way, 4-way) |
| `gf` | Open file in previous tabpage |
| `<C-w><C-f>` | Open file in split |
| `<C-w>gf` | Open file in tab |
| `R` | Refresh view |
| `g?` | Show help |

## 📊 Layouts

### Available Layouts (cycle with `g<C-x>`)

1. **diff2_horizontal** - Standard 2-way diff (side by side)
2. **diff3_horizontal** - 3-way merge tool (OURS | WORKING | THEIRS)
3. **diff3_vertical** - 3-way stacked vertically
4. **diff3_mixed** - Mixed layout (top/bottom + left/right)
5. **diff4_mixed** - 4-way with BASE column (BASE | OURS | WORKING | THEIRS)

Default for merge conflicts: **diff3_horizontal**

## 💡 Common Workflows

### Standard Merge Conflict Resolution

1. Git detects conflicts: `git merge feature-branch`
2. Open Neovim in the conflicted file
3. Diffview auto-activates with 3-way view
4. Navigate: `]x` to next conflict
5. Resolve: `<leader>co` (keep yours) or `<leader>ct` (accept theirs)
6. Repeat for all conflicts
7. Save file (`:w`) and close
8. Continue merge: `git merge --continue`

### Review Changes Before Committing

```vim
:DiffviewOpen
" or
<leader>gv
```

- Review all changed files
- Stage individual hunks by editing the index buffer (left side)
- Use `-` to stage/unstage entire files from file panel

### PR Review Workflow

```vim
:DiffviewOpen origin/main...HEAD
" or
<leader>gm
```

- View all changes in your branch vs main
- Navigate between files with `<tab>`/`<s-tab>`
- Review commit history with `<leader>gH`

### File History

```vim
:DiffviewFileHistory %
" or
<leader>gh
```

- See all commits affecting current file
- Select commit to view diff
- `y` to copy commit hash
- `X` to restore file from that commit

### Complex Conflict with 4-Way Diff

1. Start with conflict: `]x` to navigate
2. Cycle layout: `g<C-x>` until you see 4-way layout
3. Review BASE (common ancestor) to understand what changed
4. Use `1do`/`2do`/`3do` to pull hunks from BASE/OURS/THEIRS
5. Manually edit WORKING copy if needed

## 🎯 Pro Tips

1. **Diagnostics are disabled** in diff buffers for cleaner view
2. **File panel width**: 35 columns by default
3. **Tree view**: Shows files in tree structure, flattens single-child dirs
4. **Winbar info**: Enabled in merge tool to show file context
5. **Works with gitsigns**: Complementary - gitsigns for inline hunks, diffview for full diffs
6. **Lazy loaded**: Only loads when you use a diffview command (fast startup)

## 🔧 Commands

| Command | Description |
|---------|-------------|
| `:DiffviewOpen` | Open diffview (current changes) |
| `:DiffviewOpen HEAD` | Diff vs HEAD |
| `:DiffviewOpen HEAD~2` | Diff vs 2 commits ago |
| `:DiffviewOpen main..feature` | Diff range |
| `:DiffviewFileHistory` | Repo history |
| `:DiffviewFileHistory %` | Current file history |
| `:DiffviewFileHistory -- path/` | History for path |
| `:DiffviewClose` | Close diffview |
| `:DiffviewToggleFiles` | Toggle file panel |
| `:DiffviewFocusFiles` | Focus file panel |
| `:DiffviewRefresh` | Refresh view |

## 📝 Notes

- **LazyVim integration**: Follows `<leader>g` prefix for git operations
- **Conflict keys**: Use `<leader>c` prefix (code actions in LazyVim)
- **Navigation**: Standard Vim `[` and `]` conventions
- **which-key**: Press `<leader>g` to see all git commands
- **File location**: `nvim/lua/plugins/diffview.lua`

## 🆚 vs IntelliJ IDEA

| Feature | IntelliJ | Diffview |
|---------|----------|----------|
| 3-way merge | ✅ | ✅ |
| 4-way merge (with BASE) | ❌ | ✅ |
| Conflict navigation | ✅ | ✅ |
| Accept OURS/THEIRS | ✅ | ✅ |
| File history | ✅ | ✅ |
| PR review | ✅ | ✅ |
| Keyboard-driven | ⚠️ (mouse-heavy) | ✅ (fully keyboard) |
| Customizable layouts | ❌ | ✅ |
| Works in terminal | ❌ | ✅ |

## 🔗 Resources

- [diffview.nvim GitHub](https://github.com/sindrets/diffview.nvim)
- [LazyVim Documentation](https://www.lazyvim.org)
- Help: `:h diffview`
