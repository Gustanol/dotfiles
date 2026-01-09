local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local c_generator = require("commands.c-generator")
local asm = require("commands.asm-commands")
local asm_cheatsheet = require("commands.asm-cheatsheet")
local project_setup = require("commands.project-setup")
local ccls_commands = require("commands.ccls-commands")
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

-- Register commands
vim.api.nvim_create_user_command("ProjectSetup", project_setup.create_project_config, {})
vim.api.nvim_create_user_command("ProjectShow", project_setup.show_project_config, {})
vim.api.nvim_create_user_command("ProjectEdit", project_setup.edit_project_config, {})

vim.api.nvim_create_user_command("CclsOptimize", ccls_commands.optimize, {})
vim.api.nvim_create_user_command("CclsPause", ccls_commands.pause_indexing, {})
vim.api.nvim_create_user_command("CclsResume", ccls_commands.resume_indexing, {})
vim.api.nvim_create_user_command("CclsClearCache", ccls_commands.clear_cache, {})
vim.api.nvim_create_user_command("CclsStatus", ccls_commands.show_status, {})
vim.api.nvim_create_user_command("CclsDebugCompletion", ccls_commands.debug_completion, {})
-------------------------------------------- C commands

local function change_dir(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  if entry and entry.value then
    vim.cmd("cd " .. vim.fn.fnameescape(entry.value))
    vim.cmd("Telescope file_browser hidden=true")
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

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for _, client in pairs(vim.lsp.get_clients()) do
      if client and client.stop then
        client:stop()
      end
    end
  end,
})

------------------------------------------- Assembly commands
vim.api.nvim_create_user_command("AsmSyscalls", asm.show_syscalls, {})
vim.api.nvim_create_user_command("AsmRegisters", asm.show_registers, {})
vim.api.nvim_create_user_command("AsmNewProject", asm.create_project, {})
vim.api.nvim_create_user_command("AsmGotoInclude", asm.goto_include, {})
vim.api.nvim_create_user_command("AsmCheatsheet", asm_cheatsheet.show_cheatsheet, {})
------------------------------------------ Assembly commands

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("commands.markdown-commands")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    vim.keymap.set("n", "]]", "/^#\\+<CR>", { buffer = true, desc = "Next heading" })
    vim.keymap.set("n", "[[", "?^#\\+<CR>", { buffer = true, desc = "Previous heading" })

    vim.keymap.set("n", "<leader>mc", function()
      local line = vim.api.nvim_get_current_line()
      local new_line
      if line:match("^%s*- %[ %]") then
        new_line = line:gsub("^(%s*- )%[ %]", "%1[x]")
      elseif line:match("^%s*- %[x%]") then
        new_line = line:gsub("^(%s*- )%[x%]", "%1[ ]")
      else
        new_line = line:gsub("^(%s*- )", "%1[ ] ")
      end
      vim.api.nvim_set_current_line(new_line)
    end, { buffer = true, desc = "Toggle checkbox" })
  end,
})

vim.keymap.set("n", "<leader>tN", function()
  require("telescope.builtin").find_files({
    prompt_title = "Find Note Files",
    cwd = "~/notes",
  })
end, { desc = "Find note files" })
