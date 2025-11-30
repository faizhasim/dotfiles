-- Gantry LSP - Simple setup
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

      -- Register the server
      if not configs.gantry_lsp then
        configs.gantry_lsp = {
          default_config = {
            cmd = { vim.fn.expand("~/dev/seek-jobs/gantry/gantry-lsp") },
            filetypes = { "yaml.gantry" },
            root_dir = lspconfig.util.find_git_ancestor,
            name = "gantry_lsp",
          },
        }
      end

      -- Just setup like any other LSP
      lspconfig.gantry_lsp.setup({})
    end,
  },
  
  -- Detect Gantry files and set custom filetype
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function()
      vim.filetype.add({
        pattern = {
          [".*%.ya?ml"] = {
            function(path, buf)
              local content = vim.api.nvim_buf_get_lines(buf, 0, 20, false)
              for _, line in ipairs(content) do
                if line:match("^kind:%s*service") or
                   line:match("^kind:%s*environment") or
                   line:match("^kind:%s*containerimage") or
                   line:match("^kind:%s*cloudformationstack") then
                  return "yaml.gantry"
                end
              end
              return "yaml"
            end,
          },
        },
      })
    end,
  },
}
