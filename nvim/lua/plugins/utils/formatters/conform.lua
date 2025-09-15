return {
	"stevearc/conform.nvim",
	dependencies = {
		"williamboman/mason.nvim",
	},
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({
					async = true,
					lsp_fallback = true,
					timeout_ms = 3000,
				})
			end,
			mode = { "n", "v" },
			desc = "Format file or range",
		},
	},
	opts = {
		formatters_by_ft = {
			java = { "google-java-format" },
			c = { "clang-format" },
			lua = { "stylua" },
			python = { "isort", "black" },
			javascript = { { "prettierd", "prettier" } },
			typescript = { { "prettierd", "prettier" } },
			javascriptreact = { { "prettierd", "prettier" } },
			typescriptreact = { { "prettierd", "prettier" } },
			json = { { "prettierd", "prettier" } },
			html = { { "prettierd", "prettier" } },
			css = { { "prettierd", "prettier" } },
			markdown = { { "prettierd", "prettier" } },
		},

		formatters = {
			["google-java-format"] = {
				prepend_args = { "--aosp" }, -- Android Open Source Project style (4 espaços)
				timeout_ms = 5000,
			},
			["clang-format"] = {
				prepend_args = {
					"--style={IndentWidth: 4, TabWidth: 4, UseTab: Never, BreakBeforeBraces: Linux}",
				},
				timeout_ms = 3000,
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
	},

	config = function(_, opts)
		require("conform").setup(opts)

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.g.disable_autoformat = true
				print("Autoformat disabled globally")
			else
				vim.b.disable_autoformat = true
				print("Autoformat disabled for current buffer")
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
			print("Autoformat enabled")
		end, {
			desc = "Re-enable autoformat-on-save",
		})

		vim.api.nvim_create_user_command("FormatSafe", function()
			local bufnr = vim.api.nvim_get_current_buf()

			local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
			for _, client in pairs(clients) do
				if client.name == "jdtls" and client.server_capabilities.documentFormattingProvider then
					vim.defer_fn(function()
						require("conform").format({
							bufnr = bufnr,
							async = false,
							timeout_ms = 5000,
							lsp_fallback = true,
						})
					end, 500)
					return
				end
			end

			require("conform").format({
				bufnr = bufnr,
				async = false,
				timeout_ms = 3000,
				lsp_fallback = true,
			})
		end, {
			desc = "Format safely avoiding conflicts",
		})

		vim.keymap.set("n", "<leader>fs", "<cmd>FormatSafe<cr>", { desc = "Format safely" })
	end,
}
