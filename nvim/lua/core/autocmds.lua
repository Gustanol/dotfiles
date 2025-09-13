local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function change_dir(prompt_bufnr)
	local entry = action_state.get_selected_entry()
	actions.close(prompt_bufnr)
	if entry and entry.value then
		vim.cmd("cd " .. vim.fn.fnameescape(entry.value))
		vim.cmd("NvimTreeToggle")
	end
end

vim.api.nvim_create_user_command("FindProjects", function()
	require("telescope.builtin").find_files({
		search_dirs = { "~/projects" },
		find_command = {
			"fd",
			"--type",
			"d",
			"--hidden",
			"--exclude",
			".git",
			"--max-depth",
			"1",
		},
		attach_mappings = function(prompt_bufnr, map)
			map("i", "<CR>", function()
				change_dir(prompt_bufnr)
			end)
			map("n", "<CR>", function()
				change_dir(prompt_bufnr)
			end)
			return true
		end,
	})
end, {})
