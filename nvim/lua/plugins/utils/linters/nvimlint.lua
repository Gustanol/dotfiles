return {
	"mfussenegger/nvim-lint",
	dependencies = {
		"williamboman/mason.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			-- Java
			java = { "checkstyle" },

			-- C
			c = { "cppcheck" },

			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			--python = { "ruff", "mypy" },
			--lua = { "luacheck" },
			--dockerfile = { "hadolint" },
			--yaml = { "yamllint" },
			--json = { "jsonlint" },
			--markdown = { "markdownlint" },
			--sh = { "shellcheck" },
			--bash = { "shellcheck" },
			--zsh = { "shellcheck" },
		}

		lint.linters.checkstyle = {
			cmd = "checkstyle",
			stdin = false,
			args = {
				"-c",
				"/google_checks.xml",
				"--format=sarif",
			},
			stream = "stdout",
			ignore_exitcode = true,
			parser = function(output, bufnr)
				local diagnostics = {}
				local decode_ok, decoded = pcall(vim.json.decode, output)

				if not decode_ok or not decoded.runs or not decoded.runs[1] then
					return diagnostics
				end

				local results = decoded.runs[1].results or {}

				for _, result in ipairs(results) do
					for _, location in ipairs(result.locations or {}) do
						local physical_location = location.physicalLocation
						if physical_location and physical_location.region then
							local region = physical_location.region
							table.insert(diagnostics, {
								lnum = (region.startLine or 1) - 1,
								col = (region.startColumn or 1) - 1,
								end_lnum = (region.endLine or region.startLine or 1) - 1,
								end_col = (region.endColumn or region.startColumn or 1) - 1,
								severity = vim.diagnostic.severity.WARN,
								message = result.message.text or "Checkstyle issue",
								source = "checkstyle",
								code = result.ruleId,
							})
						end
					end
				end

				return diagnostics
			end,
		}

		lint.linters.cppcheck = {
			cmd = "cppcheck",
			stdin = false,
			args = {
				"--enable=all",
				"--language=c",
				"--std=c11",
				"--suppress=missingIncludeSystem",
				"--suppress=unusedFunction",
				"--quiet",
				"--template={file}:{line}:{column}: {severity}: {message} [{id}]",
			},
			stream = "stderr",
			ignore_exitcode = true,
			parser = require("lint.parser").from_pattern(
				"([^:]+):(%d+):(%d+): (%w+): (.*) %[([%w_-]+)%]",
				{ "file", "lnum", "col", "severity", "message", "code" },
				{
					severity = {
						error = vim.diagnostic.severity.ERROR,
						warning = vim.diagnostic.severity.WARN,
						style = vim.diagnostic.severity.INFO,
						performance = vim.diagnostic.severity.INFO,
						portability = vim.diagnostic.severity.HINT,
						information = vim.diagnostic.severity.INFO,
					},
				}
			),
		}

		local function do_lint()
			local max_filesize = 1024 * 1024 -- 1MB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
			if ok and stats and stats.size > max_filesize then
				return
			end

			lint.try_lint()
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = do_lint,
		})

		vim.api.nvim_create_user_command("Lint", function()
			do_lint()
		end, { desc = "Run linter on current file" })

		vim.api.nvim_create_user_command("LintStatus", function()
			local filetype = vim.bo.filetype
			local linters = lint.linters_by_ft[filetype] or {}

			if #linters == 0 then
				print("No linters configured for filetype: " .. filetype)
				return
			end

			print("Linters for " .. filetype .. ":")
			for _, linter_name in ipairs(linters) do
				local available = vim.fn.executable(linter_name) == 1
				local status = available and "✓" or "✗"
				print("  " .. status .. " " .. linter_name)

				if not available then
					if linter_name == "cppcheck" then
						print("    Install with: sudo pacman -S cppcheck")
					end
				end
			end
		end, { desc = "Check linter availability" })

		local lint_enabled = true
		vim.api.nvim_create_user_command("LintToggle", function()
			lint_enabled = not lint_enabled
			if lint_enabled then
				print("Linting enabled")
				do_lint()
			else
				print("Linting disabled")
				local ns = vim.diagnostic.get_namespace("nvim-lint")
				if ns then
					vim.diagnostic.reset(ns.id)
				end
			end
		end, { desc = "Toggle linting on/off" })

		local original_try_lint = lint.try_lint
		lint.try_lint = function(...)
			if lint_enabled then
				original_try_lint(...)
			end
		end

		local function setup_project_linting()
			local cwd = vim.fn.getcwd()

			if vim.fn.filereadable(cwd .. "/settings.gradle") == 1 or vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
				local custom_checkstyle = cwd .. "/checkstyle.xml"
				if vim.fn.filereadable(custom_checkstyle) == 1 then
					lint.linters.checkstyle.args[2] = custom_checkstyle
					print("Using project checkstyle config: " .. custom_checkstyle)
				end

				lint.linters.checkstyle.args = vim.list_extend(
					lint.linters.checkstyle.args,
					{ "--suppress=com.puppycrawl.tools.checkstyle.checks.javadoc.*" }
				)
			end

			if vim.fn.filereadable(cwd .. "/Makefile") == 1 then
				local include_dirs = {}

				for _, dir in ipairs({ "include", "src", "lib", "inc" }) do
					if vim.fn.isdirectory(cwd .. "/" .. dir) == 1 then
						table.insert(include_dirs, "-I" .. cwd .. "/" .. dir)
					end
				end

				if #include_dirs > 0 then
					lint.linters.cppcheck.args = vim.list_extend(lint.linters.cppcheck.args, include_dirs)
				end
			end
		end

		setup_project_linting()

		vim.api.nvim_create_autocmd("DirChanged", {
			group = lint_augroup,
			callback = setup_project_linting,
		})
	end,
}
