-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyLazyVim/blob/main/lua/lazyvim/config/keymaps.lua
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

-- Testing
keymap.set("n", "<leader>tr", "<cmd>Neotest run<cr>", { desc = "Run Test" })
keymap.set("n", "<leader>ts", "<cmd>Neotest summary<cr>", { desc = "Test Summary" })
keymap.set("n", "<leader>to", "<cmd>Neotest output<cr>", { desc = "Test Output" })

------------------------------------------------------
--- Telescope & NvimTree
------------------------------------------------------
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Git Branches" })
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git Commits" })

keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer" })

keymap.set("n", "<leader>cd", ":cd %:p:h<CR>:NvimTreeRefresh<CR>", { desc = "Change directory to current file" })

keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap.set("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- Quick buffer actions
keymap.set("n", "<leader>ba", "<cmd>%bd|e#|bd#<cr>", { desc = "Delete All Buffers Except Current" })
keymap.set("n", "<leader>bx", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close Other Buffers" })

-- Buffer picker
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })

------------------------------------------------------
--- Auto-save
------------------------------------------------------
keymap.set("n", "<leader>as", "<cmd>ASToggle<cr>", { desc = "Toggle Auto Save" })
keymap.set("n", "<leader>aw", function()
    vim.cmd("wa") -- Save all buffers
    vim.notify("All buffers saved!", vim.log.levels.INFO)
end, { desc = "Save All Buffers" })

-- Quick save
keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save Buffer" })
keymap.set("i", "<C-s>", "<esc><cmd>w<cr>", { desc = "Save Buffer" })
keymap.set("v", "<C-s>", "<esc><cmd>w<cr>", { desc = "Save Buffer" })
