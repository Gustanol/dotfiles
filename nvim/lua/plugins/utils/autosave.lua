return {
	"okuuva/auto-save.nvim",
	version = "*",
	cmd = "ASToggle",
	event = { "InsertLeave", "TextChanged" },
	keys = {
		{ "<leader>at", "<cmd>ASToggle<CR>", desc = "Toggle auto-save" },
	},
	opts = {},
}
