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
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        ensure_installed = {
          "clangd",
          "lua_ls",
        },
        automatic_installation = true,
        handlers = {
          -- Default handler
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = _G.lsp_config.capabilities,
              on_attach = _G.lsp_config.on_attach,
            })
          end,

          -- Clangd handler
          ["clangd"] = function()
            require("lspconfig").clangd.setup({
              capabilities = _G.lsp_config.capabilities,
              on_attach = _G.lsp_config.on_attach,
              cmd = {
                "clangd",
                "--query-driver=/usr/sbin/gcc,/usr/bin/gcc", -- match compile_commands.json
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
                "--log=verbose",
              },
              init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
              },
              filetypes = { "c", "h" },
            })
          end,

          -- Lua_ls handler
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = _G.lsp_config.capabilities,
              on_attach = _G.lsp_config.on_attach,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim" } },
                  workspace = {
                    library = {
                      [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                      [vim.fn.stdpath("config") .. "/lua"] = true,
                    },
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                },
              },
            })
          end,
        },
      })
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
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local capabilities = cmp_nvim_lsp.default_capabilities()

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
          -- linehl = { ... },
        },
      })

      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        vim.keymap.set("n", "lgd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set("n", "lgD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
        vim.keymap.set("n", "lgi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
        vim.keymap.set("n", "lgr", vim.lsp.buf.references, { desc = "Go to references" })
        vim.keymap.set("n", "lgt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

        vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action, { desc = "Code actions" })
        vim.keymap.set("n", "<leader>lrn", vim.lsp.buf.rename, { desc = "Rename" })
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, opts)

        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set(
          "n",
          "<leader>df",
          vim.diagnostic.open_float,
          { desc = "Open float diagnostics" }
        )
        vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Show warnings" })

        vim.keymap.set(
          "n",
          "<leader>lwa",
          vim.lsp.buf.add_workspace_folder,
          { desc = "Add folder to workspace" }
        )
        vim.keymap.set(
          "n",
          "<leader>lwr",
          vim.lsp.buf.remove_workspace_folder,
          { desc = "Remove folder to workspace" }
        )
        vim.keymap.set("n", "<leader>lwl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, { desc = "List all workspace folders" })

        if client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_augroup("lsp_document_highlight", {})
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = "lsp_document_highlight",
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            group = "lsp_document_highlight",
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      _G.lsp_config = {
        capabilities = capabilities,
        on_attach = on_attach,
      }
    end,
  },

  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
}
