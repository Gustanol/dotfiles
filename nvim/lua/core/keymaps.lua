vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic error" })

vim.keymap.set("n", "<leader>jf", ":JavaCreate<CR>", { desc = "Create Java file" })
vim.keymap.set("n", "<leader>jC", ":JavaClass ", { desc = "Create Java class" })
vim.keymap.set("n", "<leader>ji", ":JavaInterface ", { desc = "Create Java interface" })
vim.keymap.set("n", "<leader>js", ":JavaService ", { desc = "Create Java service" })
vim.keymap.set("n", "<leader>jr", ":JavaRepository ", { desc = "Create Java repository" })
vim.keymap.set("n", "<leader>je", ":JavaEntity ", { desc = "Create Java entity" })

vim.keymap.set("n", "<leader>cc", "<cmd>CCreateProject<cr>", { desc = "Create C project" })
vim.keymap.set("n", "<leader>ci", "<cmd>AddIncludeGuard<cr>", { desc = "Add include guard" })
vim.keymap.set("n", "<leader>ct", "<cmd>ToggleHeaderSource<cr>", { desc = "Toggle header source" })
vim.keymap.set("n", "<leader>cm", "<cmd>MakeProject<cr>", { desc = "Make C project" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "asm", "gas" },
  callback = function()
    local opts = { buffer = true, silent = true }

    vim.keymap.set(
      "n",
      "<leader>ac",
      "<cmd>AsmCompile<cr>",
      vim.tbl_extend("force", opts, { desc = "Assembly: Compilar" })
    )

    vim.keymap.set(
      "n",
      "<leader>ar",
      "<cmd>AsmRun<cr>",
      vim.tbl_extend("force", opts, { desc = "Assembly: Executar" })
    )

    vim.keymap.set(
      "n",
      "<leader>ad",
      "<cmd>AsmDebug<cr>",
      vim.tbl_extend("force", opts, { desc = "Assembly: Debug" })
    )

    vim.keymap.set(
      "n",
      "<leader>ab",
      "<cmd>lua require('dap').toggle_breakpoint()<cr>",
      vim.tbl_extend("force", opts, { desc = "Assembly: Toggle Breakpoint" })
    )

    vim.keymap.set(
      "n",
      "<leader>aB",
      "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Condition: '))<cr>",
      vim.tbl_extend("force", opts, { desc = "Assembly: Conditional breakpoint" })
    )

    vim.keymap.set(
      "n",
      "<F5>",
      "<cmd>lua require('dap').continue()<cr>",
      vim.tbl_extend("force", opts, { desc = "Debug: Continue" })
    )

    vim.keymap.set(
      "n",
      "<F10>",
      "<cmd>lua require('dap').step_over()<cr>",
      vim.tbl_extend("force", opts, { desc = "Debug: Step Over" })
    )

    vim.keymap.set(
      "n",
      "<F11>",
      "<cmd>lua require('dap').step_into()<cr>",
      vim.tbl_extend("force", opts, { desc = "Debug: Step Into" })
    )

    vim.keymap.set(
      "n",
      "<F12>",
      "<cmd>lua require('dap').step_out()<cr>",
      vim.tbl_extend("force", opts, { desc = "Debug: Step Out" })
    )

    vim.keymap.set(
      "n",
      "<leader>as",
      "<cmd>AsmSyscalls<cr>",
      vim.tbl_extend("force", opts, { desc = "Assembly: Syscalls" })
    )

    vim.keymap.set(
      "n",
      "<leader>ag",
      "<cmd>AsmRegisters<cr>",
      vim.tbl_extend("force", opts, { desc = "Assembly: Registers" })
    )
  end,
})

local opts = { noremap = true, silent = true }
vim.keymap.set(
  "n",
  "<leader>an",
  "<cmd>AsmNewProject<cr>",
  vim.tbl_extend("force", opts, { desc = "Assembly: New project" })
)
