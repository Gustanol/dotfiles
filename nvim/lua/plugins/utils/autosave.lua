return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle",
  event = { "InsertLeave", "TextChanged" },
  keys = {
    { "<leader>st", "<cmd>ASToggle<CR>", desc = "Toggle auto-save" },
  },
  opts = {
    enabled = true,
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost" },
      defer_save = { "InsertLeave", "TextChanged" },
      cancel_deferred_save = { "InsertEnter" },
    },
    condition = function(buf)
      local fn = vim.fn
      local utils = require("auto-save.utils.data")

      if fn.getbufvar(buf, "&buftype") ~= "" then
        return false
      end

      if utils.not_in(fn.getbufvar(buf, "&filetype"), { "oil" }) and fn.expand("%:t") == "" then
        return false
      end

      local clients = vim.lsp.get_clients({ bufnr = buf })
      for _, client in pairs(clients) do
        if
          client.server_capabilities.documentFormattingProvider and vim.bo[buf].modified == false
        then
          return false
        end
      end

      local max_filesize = 1024 * 1024 -- 1MB
      local file_path = vim.api.nvim_buf_get_name(buf)
      if file_path ~= "" then
        local ok, stats = pcall(vim.loop.fs_stat, file_path)
        if ok and stats and stats.size > max_filesize then
          return false
        end
      end

      return true
    end,
    debounce_delay = 1000,
    debug = false,
  },
  config = function(_, opts)
    require("auto-save").setup(opts)

    vim.api.nvim_create_user_command("ASDebug", function()
      local current_buf = vim.api.nvim_get_current_buf()
      print("Buffer: " .. current_buf)
      print("Modified: " .. tostring(vim.bo.modified))
      print("Filetype: " .. vim.bo.filetype)
      print("Filename: " .. vim.fn.expand("%:t"))

      local clients = vim.lsp.get_clients({ bufnr = current_buf })
      print("Active LSP clients: " .. #clients)
      for _, client in pairs(clients) do
        print(
          "  - "
            .. client.name
            .. " (formatting: "
            .. tostring(client.server_capabilities.documentFormattingProvider)
            .. ")"
        )
      end
    end, { desc = "Debug autosave status" })
  end,
}
