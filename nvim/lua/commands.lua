vim.api.nvim_create_user_command("JavaSwitchWorkspace", function()
    local current_dir = vim.fn.getcwd()
    vim.cmd("LspStop")
    vim.wait(1000)
    vim.cmd("edit")
end, {})

vim.api.nvim_create_user_command("JavaWorkspaceInfo", function()
    local clients = vim.lsp.get_active_clients({ name = "jdtls" })
    if #clients > 0 then
        local client = clients[1]
        print("Workspace: " .. (client.config.root_dir or "N/A"))
        print("Working Directory: " .. vim.fn.getcwd())
    else
        print("JDTLS não está ativo")
    end
end, {})

vim.keymap.set("n", "<leader>tt", function()
    local flavours = { "latte", "frappe", "macchiato", "mocha" }
    local current = vim.g.catppuccin_flavour or "mocha"
    local current_index = 1

    for i, flavour in ipairs(flavours) do
        if flavour == current then
            current_index = i
            break
        end
    end

    local next_index = (current_index % #flavours) + 1
    local next_flavour = flavours[next_index]

    require("catppuccin").setup({ flavour = next_flavour })
    vim.cmd.colorscheme("catppuccin")
    vim.g.catppuccin_flavour = next_flavour

    print("Catppuccin theme changed to: " .. next_flavour)
end, { desc = "Toggle Catppuccin flavour" })

vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer", silent = true })

vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer", silent = true })
vim.keymap.set("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force delete buffer", silent = true })

vim.keymap.set("n", "<leader>bo", ':%bdelete|edit #|normal `"<CR>', { desc = "Delete other buffers", silent = true })

vim.keymap.set("n", "<leader>ba", ":bufdo bdelete<CR>", { desc = "Delete all buffers", silent = true })

for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, ":buffer " .. i .. "<CR>", { desc = "Go to buffer " .. i, silent = true })
end

vim.keymap.set("n", "<leader>`", ":buffer#<CR>", { desc = "Alternate buffer", silent = true })
