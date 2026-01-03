local M = {}

-- Track which buffers belong to which LSP root
M.root_buffers = {}

-- Get LSP root for a buffer
local function get_lsp_root(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.config.root_dir then
      return client.config.root_dir
    end
  end
  return nil
end

-- Track buffer in root
M.track_buffer = function(bufnr)
  local root = get_lsp_root(bufnr)
  if not root then
    return
  end

  if not M.root_buffers[root] then
    M.root_buffers[root] = {}
  end

  M.root_buffers[root][bufnr] = true
end

-- Untrack buffer and stop LSP if no more buffers
M.untrack_buffer = function(bufnr)
  for root, buffers in pairs(M.root_buffers) do
    if buffers[bufnr] then
      buffers[bufnr] = nil

      -- Check if this was the last buffer for this root
      local has_buffers = false
      for _, _ in pairs(buffers) do
        has_buffers = true
        break
      end

      if not has_buffers then
        -- Stop all LSP clients for this root
        vim.schedule(function()
          local clients = vim.lsp.get_clients({ name = "ccls" })
          for _, client in ipairs(clients) do
            if client.config.root_dir == root then
              vim.notify("Stopping CCLS for: " .. vim.fn.fnamemodify(root, ":~"), vim.log.levels.INFO)
              client:stop(true)
            end
          end
          M.root_buffers[root] = nil
        end)
      end
    end
  end
end

-- Setup autocmds for lifecycle management
M.setup = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
      M.track_buffer(ev.buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(ev)
      M.untrack_buffer(ev.buf)
    end,
  })

  -- Also handle when switching away from a file
  vim.api.nvim_create_autocmd("BufWinLeave", {
    callback = function(ev)
      -- Check if buffer is no longer visible in any window
      local buf_visible = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == ev.buf then
          buf_visible = true
          break
        end
      end

      if not buf_visible then
        -- Delay check to see if buffer is really abandoned
        vim.defer_fn(function()
          if not vim.api.nvim_buf_is_valid(ev.buf) or not vim.api.nvim_buf_is_loaded(ev.buf) then
            M.untrack_buffer(ev.buf)
          end
        end, 1000)
      end
    end,
  })
end

return M
