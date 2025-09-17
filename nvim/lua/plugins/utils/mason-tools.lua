return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = { "williamboman/mason.nvim" },
	config = function()
		require("mason-tool-installer").setup({
			ensure_installed = {
				-- Formatters
				"google-java-format",
				"clang-format",
				"prettier",
				"stylua",
				"shfmt",
				"xmlformat",

				-- Linters
				"checkstyle",
				"cppcheck",
				"eslint_d",
				"luacheck",
				"shellcheck",
			},
			auto_update = true,
			run_on_start = true,
		})
	end,
}
