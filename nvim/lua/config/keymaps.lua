-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>e", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
end, {
  noremap = true,
  silent = true,
  desc = "Open mini.files (Directory of Current File)",
})

vim.keymap.set("n", "<leader>E", function()
  require("mini.files").open(vim.uv.cwd(), true)
end, {
  noremap = true,
  silent = true,
  desc = "Open mini.files (cwd)",
})
