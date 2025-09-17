return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				java = { "google-java-format" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },

				lua = { "stylua" },

				sh = { "shfmt" },
				bash = { "shfmt" },

				xml = { "xmlformat" },
			},

			formatters = {
				["google-java-format"] = {
					args = { "--aosp", "-" }, -- Android Open Source Project style
				},
				["clang-format"] = {
					args = {
						"--style={BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100}",
						"-",
					},
				},
				prettier = {
					args = {
						"--stdin-filepath",
						"$FILENAME",
						"--tab-width",
						"2",
						"--print-width",
						"100",
					},
				},
				stylua = {
					args = {
						"--indent-type",
						"Spaces",
						"--indent-width",
						"2",
						"--column-width",
						"100",
						"-",
					},
				},
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

		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })

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
