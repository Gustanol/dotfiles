return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        c = { "clangd" },
        cpp = { "clangd" },

        lua = { "lua-language-server" },

        sh = { "shfmt" },
        bash = { "shfmt" },
      },

      formatters = {
        shfmt = {
          args = { "-i", "2", "-ci", "-sr", "-" },
        },
      },

      format_on_save = nil,

      format_after_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end

        if vim.b[bufnr].conform_last_format and (vim.loop.now() - vim.b[bufnr].conform_last_format) < 1000 then
          return
        end

        vim.b[bufnr].conform_last_format = vim.loop.now()

        return {
          timeout_ms = 3000,
          lsp_fallback = true,
          async = true,
        }
      end,

      log_level = vim.log.levels.ERROR,
    })

    vim.api.nvim_create_user_command("FormatDebug", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      }, function(err)
        if err then
          vim.notify("Format error: " .. err, vim.log.levels.ERROR)
        else
          vim.notify("Formatted successfully!", vim.log.levels.INFO)
        end
      end)
    end, { desc = "Format with debug info" })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MasonToolsStartingInstall",
      callback = function()
        vim.schedule(function()
          print("Installing formatters...")
        end)
      end,
    })
  end,
}
