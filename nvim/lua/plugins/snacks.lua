return {
  "snacks.nvim",
  opts = function(_, opts)
    local logo = {
      "░▀█▀░█░█░▀█▀░█▀▀░░░▀█▀░█▀▀░░░█▀▀░▀█▀░█▀█░█▀▀░░░░░░░░░",
      "░░█░░█▀█░░█░░▀▀█░░░░█░░▀▀█░░░█▀▀░░█░░█░█░█▀▀░░░░░░░░░",
      "░░▀░░▀░▀░▀▀▀░▀▀▀░░░▀▀▀░▀▀▀░░░▀░░░▀▀▀░▀░▀░▀▀▀░▀░░▀░░▀░",
      "",
      "  Kubernetes Cluster      :  🟢  healthy (pending reality check)      ",
      "  GitHub Merge Conflicts  :  🔴  42 files need divine intervention    ",
      "  ArgoCD Sync             :  🟠  out-of-sync (but spiritually aligned)",
      "  Buildkite Pipeline      :  🟡  still running since last Friday      ",
      "  Jira Ticket             :  🟣  moved to “Almost Done (™)”           ",
      "  Git Rebase              :  🟠  branch ‘fix/fix-fix’ collapsed again ",
      "  Observability           :  🟢  metrics unknown, but vibes are good  ",
    }

    opts.dashboard.preset.header = table.concat(logo, "\n")
    opts.terminal.win.position = "float"
    opts.picker = {
      hidden = true, -- Show hidden/dotfiles by default
      sources = {
        files = {
          hidden = true, -- Show hidden/dotfiles by default
          ignored = true, -- Show ignored files (e.g., .gitignore) by default
        },
        grep = {
          hidden = true,
          ignored = true, -- Show ignored files in grep by default
        },
      },
      -- Keybindings for picker window (works in insert and normal mode)
      -- NOTE: Default <a-h>/<a-i>/<a-r> conflict with AeroSpace
      -- NOTE: Kitty protocol enabled in Zellij allows <c-h>/<c-i> to work in Neovim
      win = {
        input = {
          keys = {
            -- Toggle ignored files (useful for hiding node_modules temporarily)
            ["<c-i>"] = { "toggle_ignored", mode = { "i", "n" }, desc = "Toggle Ignored Files" },
            -- Toggle hidden/dotfiles
            ["<c-h>"] = { "toggle_hidden", mode = { "i", "n" }, desc = "Toggle Hidden Files" },
            -- Toggle regex mode (for grep)
            ["<c-x>"] = { "toggle_regex", mode = { "i", "n" }, desc = "Toggle Regex Mode" },
          },
        },
      },
    }
    opts.scroll.enabled = false
    -- Disable image support to prevent crashes on certain terminals
    opts.image = {
      enabled = false,
    }
  end,
}
