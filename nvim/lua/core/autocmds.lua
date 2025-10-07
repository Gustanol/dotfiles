local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local java_generator = require("commands.java-generator")
local c_generator = require("commands.c-generator")
local asm = require("commands.asm-commands")
local asm_cheatsheet = require("commands.asm-cheatsheet")
local asm_group = vim.api.nvim_create_augroup("AssemblyConfig", { clear = true })
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

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for _, client in pairs(vim.lsp.get_clients()) do
      if client and client.stop then
        client:stop()
      end
    end
  end,
})

------------------------------------------- Assemble commands
vim.api.nvim_create_user_command("AsmCompile", asm.compile_gas, {})
vim.api.nvim_create_user_command("AsmRun", asm.compile_and_run, {})
vim.api.nvim_create_user_command("AsmDebug", asm.compile_and_debug, {})

vim.api.nvim_create_user_command("AsmSyscalls", asm.show_syscalls, {})
vim.api.nvim_create_user_command("AsmRegisters", asm.show_registers, {})

vim.api.nvim_create_user_command("AsmNewProject", asm.create_project, {})

vim.api.nvim_create_user_command("AsmCheatsheet", asm_cheatsheet.show_cheatsheet, {})

vim.keymap.set(
  "n",
  "<leader>ah",
  "<cmd>AsmCheatsheet<cr>",
  { noremap = true, silent = true, desc = "Assembly: Cheatsheet" }
)
------------------------------------------ Assembly commands

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.s", "*.S" },
  callback = function()
    vim.bo.filetype = "gas"
  end,
  group = asm_group,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "asm", "gas" },
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
    vim.bo.commentstring = "# %s"

    vim.wo.colorcolumn = "80"

    vim.cmd([[match ExtraWhitespace /\s\+$/]])
  end,
  group = asm_group,
})

vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    local makefile = vim.fn.findfile("Makefile", ".;")
    if makefile ~= "" then
      local content = vim.fn.readfile(makefile)
      for _, line in ipairs(content) do
        if line:match("%.s") then
          vim.notify("📁 Assembly project detected (GAS)", vim.log.levels.INFO)
          break
        end
      end
    end
  end,
  group = asm_group,
})
