return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		local notify = require("notify")
		notify.setup({
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
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
			end,
			render = "default", -- compact, minimal, simple, default
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			minimum_width = 50,
			fps = 30,
			level = 1,
			top_down = true,
		})
		vim.notify = notify
		local keymap = vim.keymap.set
		local opts = { noremap = true, silent = true }

		keymap("n", "<leader>nd", function()
			notify.dismiss({ silent = true, pending = true })
		end, vim.tbl_extend("force", opts, { desc = "Dismiss notifications" }))

		keymap("n", "<leader>nh", function()
			notify.history()
		end, vim.tbl_extend("force", opts, { desc = "Show notification history" }))

		if pcall(require, "telescope") then
			pcall(require("telescope").load_extension, "notify")
			keymap("n", "<leader>tn", function()
				require("telescope").extensions.notify.notify()
			end, vim.tbl_extend("force", opts, { desc = "Search notifications" }))
		end
	end,
}
