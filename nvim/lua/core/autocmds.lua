local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local java_generator = require("commands.java-generator")
local c_generator = require("commands.c-generator")

-------------------------------------------- Java commands
local java_types = {
	"class",
	"interface",
	"enum",
	"record",
	"controller",
	"service",
	"repository",
	"entity",
	"dto",
	"test",
}

vim.api.nvim_create_user_command("JavaCreate", function()
	java_generator.create_java_interactive()
end, { desc = "Create Java file" })

for _, type in ipairs(java_types) do
	vim.api.nvim_create_user_command("Java" .. type:gsub("^%l", string.upper), function(opts)
		local args = vim.split(opts.args, " ", { trimempty = true })
		local file_name = args[1]
		local custom_package = args[2]

		if not file_name then
			print("Usage: Java" .. type:gsub("^%l", string.upper) .. " <FileName> [package]")
			return
		end

		java_generator.create_java_file(type, file_name, custom_package)
	end, {
		nargs = "*",
		desc = "Create " .. type .. " Java",
	})
end
-------------------------------------------- Java commands

-------------------------------------------- C commands
vim.api.nvim_create_user_command("CCreateProject", function()
	c_generator.create_c_project()
end, { desc = "Create C project" })

vim.api.nvim_create_user_command("AddIncludeGuard", function()
	c_generator.add_include_guard()
end, { desc = "Add include guard to header files" })

vim.api.nvim_create_user_command("ToggleHeaderSource", function()
	c_generator.toggle_header_source()
end, { desc = "Toggle header source" })

vim.api.nvim_create_user_command("MakeProject", function()
	c_generator.make_project()
end, { desc = "Make project" })
-------------------------------------------- C commands

local function change_dir(prompt_bufnr)
	local entry = action_state.get_selected_entry()
	actions.close(prompt_bufnr)
	if entry and entry.value then
		vim.cmd("cd " .. vim.fn.fnameescape(entry.value))
		vim.cmd("Telescope file_browser")
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

vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		for _, client in pairs(vim.lsp.get_active_clients()) do
			client.stop()
		end
	end,
})
