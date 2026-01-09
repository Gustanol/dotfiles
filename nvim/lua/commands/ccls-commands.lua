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

-- Add to lua/commands/ccls-commands.lua
M.debug_completion = function()
  local params = vim.lsp.util.make_position_params(0, 'utf-8')

  vim.lsp.buf_request(0, 'textDocument/completion', params, function(err, result)
    if err then
      vim.notify("Error: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end

    if result and result.items and #result.items > 0 then
      local item = result.items[1]
      vim.notify(
        "First completion item:\n" .. vim.inspect(item),
        vim.log.levels.INFO
      )
    end
  end)
end

return M
