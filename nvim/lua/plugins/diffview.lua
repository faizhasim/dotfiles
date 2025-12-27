return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      -- Diffview operations
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview (Current Changes)" },
      { "<leader>gV", "<cmd>DiffviewOpen HEAD<cr>", desc = "Diffview (vs HEAD)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (Diffview)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo History (Diffview)" },
      { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "PR Diff (vs main)" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    opts = function()
      local actions = require("diffview.actions")

      return {
        enhanced_diff_hl = true, -- Better syntax highlighting in diffs
        view = {
          default = {
            -- Config for regular diffs (changed files, staged files)
            layout = "diff2_horizontal",
            disable_diagnostics = false,
            winbar_info = false,
          },
          merge_tool = {
            -- Config for merge conflicts (3-way diff by default)
            layout = "diff3_horizontal",
            disable_diagnostics = true, -- Cleaner view during conflicts
            winbar_info = true, -- Show file info in winbar
          },
          file_history = {
            -- Config for file history view
            layout = "diff2_horizontal",
            disable_diagnostics = false,
            winbar_info = false,
          },
        },
        file_panel = {
          listing_style = "tree", -- Tree view for files
          tree_options = {
            flatten_dirs = true, -- Flatten single-child directories
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
          },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = "combined",
              },
              multi_file = {
                diff_merges = "first-parent",
              },
            },
          },
          win_config = {
            position = "bottom",
            height = 16,
          },
        },
        keymaps = {
          disable_defaults = false,
          view = {
            -- Navigation
            { "n", "<tab>", actions.select_next_entry, { desc = "Next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Previous file" } },
            { "n", "[F", actions.select_first_entry, { desc = "First file" } },
            { "n", "]F", actions.select_last_entry, { desc = "Last file" } },

            -- Conflict navigation
            { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },

            -- Conflict resolution - single hunk/region
            { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
            { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
            { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE" } },
            { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose ALL" } },
            { "n", "<leader>cn", actions.conflict_choose("none"), { desc = "Delete conflict region" } },

            -- Conflict resolution - whole file
            { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose OURS (whole file)" } },
            { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose THEIRS (whole file)" } },
            { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose BASE (whole file)" } },
            { "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "Choose ALL (whole file)" } },
            { "n", "<leader>cN", actions.conflict_choose_all("none"), { desc = "Delete all conflicts" } },

            -- File panel
            { "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
            { "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },

            -- Layout cycling
            { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layouts" } },

            -- Open file
            { "n", "gf", actions.goto_file_edit, { desc = "Open file" } },
            { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
            { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in tab" } },

            -- Refresh
            { "n", "R", actions.refresh_files, { desc = "Refresh" } },

            -- Help
            { "n", "g?", actions.help({ "view" }), { desc = "Open help" } },
          },
          diff3 = {
            -- 3-way diff specific mappings
            { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "Get hunk from OURS" } },
            { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "Get hunk from THEIRS" } },
          },
          diff4 = {
            -- 4-way diff specific mappings
            { { "n", "x" }, "1do", actions.diffget("base"), { desc = "Get hunk from BASE" } },
            { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "Get hunk from OURS" } },
            { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "Get hunk from THEIRS" } },
          },
          file_panel = {
            { "n", "j", actions.next_entry, { desc = "Next entry" } },
            { "n", "k", actions.prev_entry, { desc = "Previous entry" } },
            { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
            { "n", "o", actions.select_entry, { desc = "Open diff" } },
            { "n", "l", actions.select_entry, { desc = "Open diff" } },
            { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open diff" } },

            -- Staging
            { "n", "-", actions.toggle_stage_entry, { desc = "Stage/unstage" } },
            { "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage" } },
            { "n", "S", actions.stage_all, { desc = "Stage all" } },
            { "n", "U", actions.unstage_all, { desc = "Unstage all" } },

            -- Restore
            { "n", "X", actions.restore_entry, { desc = "Restore file" } },

            -- Folds
            { "n", "zo", actions.open_fold, { desc = "Open fold" } },
            { "n", "h", actions.close_fold, { desc = "Close fold" } },
            { "n", "zc", actions.close_fold, { desc = "Close fold" } },
            { "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
            { "n", "zR", actions.open_all_folds, { desc = "Open all folds" } },
            { "n", "zM", actions.close_all_folds, { desc = "Close all folds" } },

            -- Navigation
            { "n", "<tab>", actions.select_next_entry, { desc = "Next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Previous file" } },
            { "n", "[F", actions.select_first_entry, { desc = "First file" } },
            { "n", "]F", actions.select_last_entry, { desc = "Last file" } },

            -- Conflict navigation
            { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },

            -- Conflict resolution from file panel
            { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
            { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
            { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE" } },
            { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose ALL" } },
            { "n", "<leader>cn", actions.conflict_choose("none"), { desc = "Delete conflict" } },
            { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose OURS (whole file)" } },
            { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose THEIRS (whole file)" } },
            { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose BASE (whole file)" } },
            { "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "Choose ALL (whole file)" } },
            { "n", "<leader>cN", actions.conflict_choose_all("none"), { desc = "Delete all conflicts" } },

            -- Open file
            { "n", "gf", actions.goto_file_edit, { desc = "Open file" } },
            { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
            { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in tab" } },

            -- View options
            { "n", "i", actions.listing_style, { desc = "Toggle tree/list" } },
            { "n", "f", actions.toggle_flatten_dirs, { desc = "Toggle flatten dirs" } },
            { "n", "R", actions.refresh_files, { desc = "Refresh" } },

            -- Focus
            { "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
            { "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },

            -- Layout
            { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layouts" } },

            -- Help
            { "n", "g?", actions.help("file_panel"), { desc = "Open help" } },
          },
          file_history_panel = {
            { "n", "g!", actions.options, { desc = "Options" } },
            { "n", "<C-A-d>", actions.open_in_diffview, { desc = "Open in diffview" } },
            { "n", "y", actions.copy_hash, { desc = "Copy commit hash" } },
            { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
            { "n", "X", actions.restore_entry, { desc = "Restore file" } },

            -- Folds
            { "n", "zo", actions.open_fold, { desc = "Open fold" } },
            { "n", "h", actions.close_fold, { desc = "Close fold" } },
            { "n", "zc", actions.close_fold, { desc = "Close fold" } },
            { "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
            { "n", "zR", actions.open_all_folds, { desc = "Open all folds" } },
            { "n", "zM", actions.close_all_folds, { desc = "Close all folds" } },

            -- Navigation
            { "n", "j", actions.next_entry, { desc = "Next entry" } },
            { "n", "k", actions.prev_entry, { desc = "Previous entry" } },
            { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
            { "n", "o", actions.select_entry, { desc = "Open diff" } },
            { "n", "l", actions.select_entry, { desc = "Open diff" } },
            { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open diff" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "Next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Previous file" } },
            { "n", "[F", actions.select_first_entry, { desc = "First file" } },
            { "n", "]F", actions.select_last_entry, { desc = "Last file" } },

            -- Open file
            { "n", "gf", actions.goto_file_edit, { desc = "Open file" } },
            { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
            { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in tab" } },

            -- Focus
            { "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
            { "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },

            -- Layout
            { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layouts" } },

            -- Help
            { "n", "g?", actions.help("file_history_panel"), { desc = "Open help" } },
          },
        },
        hooks = {
          diff_buf_read = function(bufnr)
            -- Disable diagnostics in diff buffers for cleaner view
            local diagnostic = vim and vim.diagnostic
            if diagnostic then
              diagnostic.enable(false, { bufnr = bufnr })
            end
          end,
        },
      }
    end,
  },

  -- Optional: Configure which-key groups for better discoverability
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
      },
    },
  },
}
