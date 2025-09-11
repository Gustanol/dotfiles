-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Java specific keymaps
keymap.set("n", "<leader>jo", "<cmd>lua require('jdtls').organize_imports()<cr>", { desc = "Organize Imports" })
keymap.set("n", "<leader>jv", "<cmd>lua require('jdtls').extract_variable()<cr>", { desc = "Extract Variable" })
keymap.set("n", "<leader>jc", "<cmd>lua require('jdtls').extract_constant()<cr>", { desc = "Extract Constant" })
keymap.set("n", "<leader>jm", "<cmd>lua require('jdtls').extract_method(true)<cr>", { desc = "Extract Method" })
keymap.set(
    "n",
    "<leader>ju",
    "<cmd>lua require('jdtls').update_project_config()<cr>",
    { desc = "Update Project Config" }
)
keymap.set("n", "<leader>jt", "<cmd>lua require('jdtls').test_nearest_method()<cr>", { desc = "Test Method" })
keymap.set("n", "<leader>jT", "<cmd>lua require('jdtls').test_class()<cr>", { desc = "Test Class" })

-- Spring Boot specific
keymap.set("n", "<leader>sb", "<cmd>!./mvnw spring-boot:run<cr>", { desc = "Spring Boot Run" })
keymap.set("n", "<leader>st", "<cmd>!./mvnw test<cr>", { desc = "Run Tests" })
keymap.set("n", "<leader>sc", "<cmd>!./mvnw clean compile<cr>", { desc = "Clean Compile" })
keymap.set("n", "<leader>sp", "<cmd>!./mvnw package<cr>", { desc = "Package" })

-- Multi-project navigation
keymap.set("n", "<leader>pf", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
keymap.set("n", "<leader>pg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
keymap.set("n", "<leader>pb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
keymap.set("n", "<leader>pr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent Files" })
keymap.set("n", "<leader>pp", "<cmd>Telescope projects<cr>", { desc = "Projects" })

-- Git
keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Git Branches" })
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git Commits" })

-- Testing
keymap.set("n", "<leader>tr", "<cmd>Neotest run<cr>", { desc = "Run Test" })
keymap.set("n", "<leader>ts", "<cmd>Neotest summary<cr>", { desc = "Test Summary" })
keymap.set("n", "<leader>to", "<cmd>Neotest output<cr>", { desc = "Test Output" })
