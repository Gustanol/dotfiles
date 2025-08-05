-- ~/.config/nvim/lua/keymaps.lua
local microservices = require("microservices")

vim.keymap.set("n", "<leader>ms", microservices.switch_service, { desc = "Switch Microservice" })
vim.keymap.set("n", "<leader>mr", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })
vim.keymap.set("n", "<leader>mw", "<cmd>pwd<cr>", { desc = "Show Working Directory" })

vim.keymap.set("n", "<leader>jo", '<cmd>lua require("jdtls").organize_imports()<cr>', { desc = "Organize Imports" })
vim.keymap.set("n", "<leader>jv", '<cmd>lua require("jdtls").extract_variable()<cr>', { desc = "Extract Variable" })
vim.keymap.set("n", "<leader>jc", '<cmd>lua require("jdtls").extract_constant()<cr>', { desc = "Extract Constant" })
vim.keymap.set("v", "<leader>jm", '<cmd>lua require("jdtls").extract_method(true)<cr>', { desc = "Extract Method" })
