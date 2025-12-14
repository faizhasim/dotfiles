-- Local Neovim config for docs/
-- Disable auto-formatting for SLIDES.md to preserve trailing spaces for Nerd Font icons
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = "SLIDES.md",
  callback = function()
    vim.b.autoformat = false
  end,
})
