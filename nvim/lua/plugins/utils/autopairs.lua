return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		require("nvim-autopairs").setup({
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
			check_ts = true,
			enable_afterquote = true,
			enable_moveright = true,
			map_cr = true,
			map_bs = true,
		})
	end,
}
