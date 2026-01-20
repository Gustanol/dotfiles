return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle",
  event = { "InsertLeave", "TextChanged" },
  keys = {
    { "<cmd>ASToggle<CR>", desc = "Toggle auto-save" },
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
  end,
}
