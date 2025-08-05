-- ~/.config/nvim/lua/commands.lua
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
