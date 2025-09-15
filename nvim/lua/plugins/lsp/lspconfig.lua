return {
	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			-- Capabilities from nvim-cmp
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Improved LSP diagnostics
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					source = "if_many",
				},
				float = {
					source = "always",
					border = "rounded",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- LSP signs
			local signs = {
				Error = " ",
				Warn = " ",
				Hint = " ",
				Info = " ",
			}

			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			-- LSP handlers with better UI
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
			})

			-- Key mappings function
			local function on_attach(client, bufnr)
				local opts = { buffer = bufnr, silent = true }

				-- LSP key mappings
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set(
					"n",
					"<leader>lwa",
					vim.lsp.buf.add_workspace_folder,
					opts,
					{ desc = "Add a folder to workspace" }
				)
				vim.keymap.set(
					"n",
					"<leader>lwr",
					vim.lsp.buf.remove_workspace_folder,
					opts,
					{ desc = "Remove a folder from workspace" }
				)
				vim.keymap.set("n", "<leader>lwl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts, { desc = "List folder from workspace" })
				vim.keymap.set("n", "<leader>c", vim.lsp.buf.type_definition, opts)
				--vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set({ "n", "v" }, "<leader>lca", vim.lsp.buf.code_action, opts, { desc = "Code actions" })
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

				-- Diagnostics
				vim.keymap.set("n", "<leader>Le", vim.diagnostic.open_float, opts, { desc = "Open diagnostics" })
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				--vim.keymap.set("n", "<leader>Lq", vim.diagnostic.setloclist, opts)

				-- Format on save
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								timeout_ms = 3000,
								filter = function(c)
									return c.id == client.id
								end,
							})
						end,
					})
				end
			end

			lspconfig.clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
				filetypes = { "c" },
				root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".clangd", ".git"),
			})
		end,
	},
}
