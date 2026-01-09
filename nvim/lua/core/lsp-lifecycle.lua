local M = {}

-- Track which buffers belong to which server
M.server_buffers = {}

-- Track buffer for a specific server
M.track_buffer = function(bufnr, server_name)
  if not M.server_buffers[server_name] then
    M.server_buffers[server_name] = {}
  end

  M.server_buffers[server_name][bufnr] = true
end

-- Untrack buffer and stop server if no more buffers
M.untrack_buffer = function(bufnr)
  for server_name, buffers in pairs(M.server_buffers) do
    if buffers[bufnr] then
      buffers[bufnr] = nil

      -- Check if this was the last buffer for this server
      local has_buffers = false
      for _, _ in pairs(buffers) do
        has_buffers = true
        break
      end

      if not has_buffers then
        -- Stop this specific server
        vim.schedule(function()
          local clients = vim.lsp.get_clients({ name = server_name })
          for _, client in ipairs(clients) do
            print("Stopping " .. server_name)
            client:stop(true)
          end
          M.server_buffers[server_name] = nil
        end)
      end
    end
  end
end

-- Setup autocmds
M.setup = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client.name:match("^ccls_") then
        M.track_buffer(ev.buf, client.name)
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(ev)
      M.untrack_buffer(ev.buf)
    end,
  })
end

return M
