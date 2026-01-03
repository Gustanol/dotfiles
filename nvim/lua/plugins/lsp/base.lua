return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
        automatic_enable = false,
      })

      require("lsp.servers.ccls")
      require("lsp.servers.lua_ls")
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "if_many",
        },
        float = {
          source = true,
          border = "rounded",
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = " ",
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignErrorError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarnWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfoInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHintHint",
          },
        },
      })
    end,
  },

  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
}
