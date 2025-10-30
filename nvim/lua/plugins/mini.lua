return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.explorer.enabled = false
    end,
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>E", false },
      { "<leader>e", false },
    },
  },
  {
    "nvim-mini/mini.files",
    lazy = false,
    opts = {
      options = {
        use_as_default_explorer = true,
      },
    },
  },
}
