return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		spec = {
			{ "<leader>t", group = "Telescope" },
			{ "<leader>a", group = "Auto-save" },
			{ "<leader>L", group = "Linting" },
			{ "<leader>d", group = "Diagnostics" },
			{ "<leader>n", group = "Notifications" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>Lw", group = "Workspace" },
			{ "<leader>c", group = "C keymaps" },
			{ "<leader>j", group = "Java" },
		},
	},
}
