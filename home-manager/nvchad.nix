{ config, pkgs, lib, inputs, ... }: {
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];
  programs.nvchad = {
    enable = true;
    chadrcConfig = ''
    -- This file needs to have same structure as nvconfig.lua
    -- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
    -- Please read that file to know all available options :(

    ---@type ChadrcConfig
    local M = {}

    M.base46 = {
    	theme = "nord",

    	-- hl_override = {
    	-- 	Comment = { italic = true },
    	-- 	["@comment"] = { italic = true },
    	-- },
    }

    -- M.nvdash = { load_on_startup = true }
    -- M.ui = {
    --       tabufline = {
    --          lazyload = false
    --      }
    -- }

    return M
    '';
    extraPlugins = ''
    return {
       {
          "xiyaowong/transparent.nvim",
          event = "VeryLazy",
          enabled = true,
          config = function()
            require("transparent").clear_prefix("WinBar")
            require("transparent").clear_prefix("Navic")
            require("transparent").clear_prefix("Float")
            require("transparent").clear_prefix("Normal")
            require("transparent").clear_prefix("NeoTree")
            require("transparent").clear_prefix("Noice")
            require("transparent").clear_prefix("Notify")
            require("transparent").clear_prefix("GitSigns")
            require("transparent").clear_prefix("Mini")
            require("transparent").clear_prefix("WhichKey")
            require("transparent").clear_prefix("BufferLine")
            require("transparent").clear_prefix("Tab")
            require("transparent").clear_prefix("Telescope")
            require("transparent").setup({ -- Optional, you don't have to run setup.
              groups = { -- table: default groups
                "Comment",
                "Constant",
                "TabLineFill",
                "Special",
                "WinBar",
                "Identifier",
                "Statement",
                "PreProc",
                "Type",
                "Underlined",
                "Todo",
                "String",
                "Function",
                "Conditional",
                "Repeat",
                "Operator",
                "Structure",
                "LineNr",
                "NonText",
                "SignColumn",
                "StatusLine",
                "StatusLineNC",
                "EndOfBuffer",
                "SignColumn",
                "HoverNormal",
              },
              extra_groups = {
                "OctoEditable",
                "EndOfBuffer",
                "Search",
                "Cursor",
                "LazyNormal",
              }, -- table: additional groups that should be cleared
              exclude_groups = {}, -- table: groups you don't want to clear
              on_clear = function() end,
            })
          end,
      },
      {
        "github/copilot.vim",
        enabled = true,
        lazy = false,
      },
    }
    '';
  };
}
