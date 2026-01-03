vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic error" })

vim.keymap.set("n", "<leader>cc", "<cmd>CCreateProject<cr>", { desc = "Create C project" })
vim.keymap.set("n", "<leader>ci", "<cmd>AddIncludeGuard<cr>", { desc = "Add include guard" })
vim.keymap.set("n", "<leader>ct", "<cmd>ToggleHeaderSource<cr>", { desc = "Toggle header source" })
vim.keymap.set("n", "<leader>cm", "<cmd>MakeProject<cr>", { desc = "Make C project" })
vim.api.nvim_set_keymap('n', '<Tab>', '<C-w>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "asm", "gas" },
  callback = function()
    local opts = { buffer = true, silent = true }

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
