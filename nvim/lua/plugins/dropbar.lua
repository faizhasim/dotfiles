return {
  {
    "Bekaboo/dropbar.nvim",
    lazy = false,
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
  },
}
