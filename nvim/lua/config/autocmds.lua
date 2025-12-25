-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- User commands to toggle formatting (conform.nvim)
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
    vim.notify("Autoformat disabled for current buffer", vim.log.levels.INFO)
  else
    vim.g.disable_autoformat = true
    vim.notify("Autoformat disabled globally", vim.log.levels.INFO)
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
  vim.notify("Autoformat re-enabled", vim.log.levels.INFO)
end, {
  desc = "Re-enable autoformat-on-save",
})

-- Show current format status
vim.api.nvim_create_user_command("FormatStatus", function()
  local global_status = vim.g.disable_autoformat and "disabled" or "enabled"
  local buffer_status = vim.b.disable_autoformat and "disabled" or "enabled"
  vim.notify(
    string.format("Autoformat - Global: %s, Buffer: %s", global_status, buffer_status),
    vim.log.levels.INFO
  )
end, {
  desc = "Show autoformat status",
})
