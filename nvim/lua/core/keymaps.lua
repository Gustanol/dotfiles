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
