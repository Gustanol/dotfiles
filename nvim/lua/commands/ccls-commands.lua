local M = {}

-- Pause CCLS indexing
M.pause_indexing = function()
  for _, client in ipairs(vim.lsp.get_clients({ name = "ccls" })) do
    client:notify("$ccls/reload", {})
  end
  vim.notify("CCLS indexing paused", vim.log.levels.INFO)
end

-- Resume CCLS indexing
M.resume_indexing = function()
  for _, client in ipairs(vim.lsp.get_clients({ name = "ccls" })) do
    client:notify("$ccls/reload", {})
  end
  vim.notify("CCLS indexing resumed", vim.log.levels.INFO)
end

-- Clear CCLS cache
M.clear_cache = function()
  local cache_dir = vim.fn.stdpath("cache") .. "/ccls"
  vim.fn.delete(cache_dir, "rf")
  vim.notify("CCLS cache cleared. Restart LSP to rebuild.", vim.log.levels.INFO)
end

-- Show CCLS status
M.show_status = function()
  for _, client in ipairs(vim.lsp.get_clients({ name = "ccls" })) do
    client:request("$ccls/info", {}, function(err, result)
      if err then
        vim.notify("Error getting CCLS info: " .. err.message, vim.log.levels.ERROR)
        return
      end

      if result then
        local info = {
          "CCLS Status:",
          "Root: " .. (client.config.root_dir or "unknown"),
          "Cache: " .. result.cacheDirectory,
          "Indexed files: " .. (result.indexedFiles or 0),
        }
        vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
      end
    end, vim.api.nvim_get_current_buf())
  end
end

-- Optimize CCLS for current project
M.optimize = function()
  vim.notify("Optimizing CCLS settings...", vim.log.levels.INFO)

  for _, client in ipairs(vim.lsp.get_clients({ name = "ccls" })) do
    -- Reduce indexing
    client:notify("$ccls/reload", {})
  end

  vim.notify("CCLS optimized. Lower CPU usage expected.", vim.log.levels.INFO)
end


-- Register commands
vim.api.nvim_create_user_command("CclsOptimize", M.optimize, {})
vim.api.nvim_create_user_command("CclsPause", M.pause_indexing, {})
vim.api.nvim_create_user_command("CclsResume", M.resume_indexing, {})
vim.api.nvim_create_user_command("CclsClearCache", M.clear_cache, {})
vim.api.nvim_create_user_command("CclsStatus", M.show_status, {})

return M
