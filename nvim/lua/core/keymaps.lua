vim.keymap.set("n", "<leader>Ll", "<cmd>Lint<cr>", { desc = "Run linter" })
vim.keymap.set("n", "<leader>Lt", "<cmd>LintToggle<cr>", { desc = "Toggle linting" })
vim.keymap.set("n", "<leader>Ls", "<cmd>LintStatus<cr>", { desc = "Check linter status" })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Set diagnostics to location list" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Set diagnostics to quickfix list" })

vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic error" })

vim.keymap.set("n", "<leader>jc", ":JavaCreate<CR>", { desc = "Create Java file" })
vim.keymap.set("n", "<leader>jC", ":JavaClass ", { desc = "Create Java class" })
vim.keymap.set("n", "<leader>ji", ":JavaInterface ", { desc = "Create Java interface" })
vim.keymap.set("n", "<leader>js", ":JavaService ", { desc = "Create Java service" })
vim.keymap.set("n", "<leader>jr", ":JavaRepository ", { desc = "Create Java repository" })
vim.keymap.set("n", "<leader>je", ":JavaEntity ", { desc = "Create Java entity" })
