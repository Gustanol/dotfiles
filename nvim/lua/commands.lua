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
