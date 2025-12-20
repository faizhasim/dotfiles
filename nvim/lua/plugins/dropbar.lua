return {
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy", -- Changed from lazy=false to prevent startup race conditions
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    keys = {
      {
        "<leader>;",
        function()
          local dropbar_api = require("dropbar.api")
          dropbar_api.pick()
        end,
        desc = "Pick symbols in winbar",
      },
    },
    opts = {
      -- Disable dropbar in certain filetypes to prevent crashes
      enable = function(buf, win, _)
        local ft = vim.bo[buf].filetype
        local excluded_fts = { "help", "terminal", "prompt", "TelescopePrompt", "neo-tree", "dashboard" }
        return not vim.tbl_contains(excluded_fts, ft)
      end,
    },
  },
}
