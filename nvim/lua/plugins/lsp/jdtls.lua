return {
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local jdtls = require("jdtls")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			local function get_project_type_and_root()
				local current_dir = vim.fn.expand("%:p:h")

				local gradle_root = vim.fs.find("settings.gradle", {
					path = current_dir,
					upward = true,
				})[1]

				if gradle_root then
					return "gradle", vim.fs.dirname(gradle_root)
				end

				local gradle_build = vim.fs.find("build.gradle", {
					path = current_dir,
					upward = true,
				})[1]

				if gradle_build then
					return "gradle", vim.fs.dirname(gradle_build)
				end

				local maven_root = vim.fs.find("pom.xml", {
					path = current_dir,
					upward = true,
				})[1]

				if maven_root then
					return "maven", vim.fs.dirname(maven_root)
				end

				local git_root = vim.fs.find(".git", {
					path = current_dir,
					upward = true,
				})[1]

				if git_root then
					return "unknown", vim.fs.dirname(git_root)
				end

				return "unknown", current_dir
			end

			local function setup_jdtls()
				local project_type, root_dir = get_project_type_and_root()
				local project_name = vim.fs.basename(root_dir)
				local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

				local mason_registry = require("mason-registry")
				local jdtls_pkg = mason_registry.get_package("jdtls")
				local jdtls_path = jdtls_pkg:get_install_path()

				local system = "linux"
				local init_options = {
					bundles = {},
					extendedClientCapabilities = jdtls.extendedClientCapabilities,
				}

				if project_type == "gradle" then
					init_options.settings = {
						java = {
							configuration = {
								updateBuildConfiguration = "interactive",
							},
							gradle = {
								enabled = true,
								wrapper = {
									enabled = true,
								},
							},
							import = {
								gradle = {
									enabled = true,
									wrapper = {
										enabled = true,
									},
									version = "",
									home = "",
								},
							},
						},
					}
				end

				if project_type == "maven" then
					init_options.settings = {
						java = {
							configuration = {
								updateBuildConfiguration = "interactive",
							},
							maven = {
								downloadSources = true,
							},
							import = {
								maven = {
									enabled = true,
								},
							},
						},
					}
				end

				local config = {
					cmd = {
						"java",
						"-Declipse.application=org.eclipse.jdt.ls.core.id1",
						"-Dosgi.bundles.defaultStartLevel=4",
						"-Declipse.product=org.eclipse.jdt.ls.core.product",
						"-Dlog.protocol=true",
						"-Dlog.level=ALL",
						"-Xmx1g",
						"--add-modules=ALL-SYSTEM",
						"--add-opens",
						"java.base/java.util=ALL-UNNAMED",
						"--add-opens",
						"java.base/java.lang=ALL-UNNAMED",
						"-jar",
						vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
						"-configuration",
						jdtls_path .. "/config_" .. system,
						"-data",
						workspace_dir,
					},

					root_dir = root_dir,

					capabilities = cmp_nvim_lsp.default_capabilities(),

					settings = {
						java = {
							eclipse = {
								downloadSources = true,
							},
							configuration = {
								updateBuildConfiguration = "interactive",
								runtimes = {
									{
										name = "JavaSE-21",
										path = "/usr/lib/jvm/java-21-openjdk/",
									},
									{
										name = "JavaSE-24",
										path = "/usr/lib/jvm/java-24-openjdk/",
									},
								},
							},
							maven = {
								downloadSources = true,
							},
							implementationsCodeLens = {
								enabled = true,
							},
							referencesCodeLens = {
								enabled = true,
							},
							references = {
								includeDecompiledSources = true,
							},
							format = {
								enabled = true,
								settings = {
									url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
									profile = "GoogleStyle",
								},
							},
						},
						signatureHelp = { enabled = true },
						completion = {
							favoriteStaticMembers = {
								"org.hamcrest.MatcherAssert.assertThat",
								"org.hamcrest.Matchers.*",
								"org.hamcrest.CoreMatchers.*",
								"org.junit.jupiter.api.Assertions.*",
								"java.util.Objects.requireNonNull",
								"java.util.Objects.requireNonNullElse",
								"org.mockito.Mockito.*",
							},
							importOrder = {
								"java",
								"javax",
								"com",
								"org",
							},
						},
						contentProvider = { preferred = "fernflower" },
						extendedClientCapabilities = jdtls.extendedClientCapabilities,
						sources = {
							organizeImports = {
								starThreshold = 9999,
								staticStarThreshold = 9999,
							},
						},
						codeGeneration = {
							toString = {
								template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
							},
							useBlocks = true,
						},
					},

					init_options = init_options,

					on_attach = function(client, bufnr)
						local opts = { buffer = bufnr, silent = true }

						vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
						vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
						vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
						vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
						vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
						vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
						vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
						vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
						vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

						vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { desc = "Organize Imports" })
						vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, { desc = "Extract Variable" })
						vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, { desc = "Extract Constant" })
						vim.keymap.set(
							"v",
							"<leader>jm",
							[[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
							{ desc = "Extract Method" }
						)

						vim.keymap.set("n", "<leader>df", jdtls.test_class, { desc = "Debug Test Class" })
						vim.keymap.set("n", "<leader>dn", jdtls.test_nearest_method, { desc = "Debug Test Method" })

						-- Workspace commands
						vim.keymap.set("n", "<leader>jw", function()
							print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
						end, { desc = "List Workspace Folders" })

						-- Auto format on save
						if client.supports_method("textDocument/formatting") then
							vim.api.nvim_create_autocmd("BufWritePre", {
								group = vim.api.nvim_create_augroup("LspFormatJava." .. bufnr, {}),
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

						-- Print project info
						print("Java project detected: " .. project_type .. " at " .. root_dir)
					end,
				}

				jdtls.start_or_attach(config)
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = setup_jdtls,
			})
		end,
	},
}
