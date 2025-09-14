return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		spec = {
			{ "<leader>t", group = "Telescope" },
			{ "<leader>a", group = "Auto-save" },
			{ "<leader>l", group = "Linting" },
			{ "<leader>d", group = "Diagnostics" },
			{ "<leader>n", group = "Notifications" },
		},
	},
}
