return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	opts = {
		stages = "fade_in_slide_out",
		timeout = 3000,
		background_colour = "#000000",
		icons = {
			ERROR = "",
			WARN = "",
			INFO = "",
			DEBUG = "",
			TRACE = "✎",
		},
		max_width = 50,
		max_height = 10,
		render = "compact",
		top_down = true,
	},
	config = function(_, opts)
		local notify = require("notify")
		notify.setup(opts)
		vim.notify = notify

		vim.keymap.set("n", "<leader>nd", function()
			notify.dismiss({ silent = true, pending = true })
		end, { desc = "Dismiss notifications" })
	end,
}
