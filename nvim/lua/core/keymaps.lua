vim.keymap.set("n", "<leader>ll", "<cmd>Lint<cr>", { desc = "Run linter" })
vim.keymap.set("n", "<leader>lt", "<cmd>LintToggle<cr>", { desc = "Toggle linting" })
vim.keymap.set("n", "<leader>ls", "<cmd>LintStatus<cr>", { desc = "Check linter status" })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Set diagnostics to location list" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Set diagnostics to quickfix list" })

vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic error" })
