-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Gantry LSP Helper Commands
vim.api.nvim_create_user_command("GantryLspInfo", function()
  local clients = vim.lsp.get_active_clients({ name = "gantry-lsp" })
  if #clients > 0 then
    vim.notify("Gantry LSP is active ✓", vim.log.levels.INFO, { title = "Gantry LSP" })
    for _, client in ipairs(clients) do
      print(string.format("Client ID: %d, Root: %s", client.id, client.config.root_dir))
    end
  else
    vim.notify("Gantry LSP is not active", vim.log.levels.WARN, { title = "Gantry LSP" })
  end
end, { desc = "Show Gantry LSP status" })

vim.api.nvim_create_user_command("GantryLspRestart", function()
  local clients = vim.lsp.get_active_clients({ name = "gantry-lsp" })
  if #clients == 0 then
    vim.notify("Gantry LSP is not running", vim.log.levels.WARN, { title = "Gantry LSP" })
    return
  end
  
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  
  vim.notify("Gantry LSP stopped, restarting...", vim.log.levels.INFO, { title = "Gantry LSP" })
  
  vim.defer_fn(function()
    vim.cmd("edit") -- Reload buffer to trigger autocmd
    vim.notify("Gantry LSP restarted", vim.log.levels.INFO, { title = "Gantry LSP" })
  end, 500)
end, { desc = "Restart Gantry LSP server" })

vim.api.nvim_create_user_command("GantryLspStop", function()
  local clients = vim.lsp.get_active_clients({ name = "gantry-lsp" })
  if #clients == 0 then
    vim.notify("Gantry LSP is not running", vim.log.levels.WARN, { title = "Gantry LSP" })
    return
  end
  
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  vim.notify("Gantry LSP stopped", vim.log.levels.INFO, { title = "Gantry LSP" })
end, { desc = "Stop Gantry LSP server" })

vim.api.nvim_create_user_command("GantryLspLog", function()
  vim.cmd("edit " .. vim.lsp.get_log_path())
end, { desc = "Open Gantry LSP log file" })
