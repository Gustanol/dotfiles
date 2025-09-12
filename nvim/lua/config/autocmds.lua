-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local auto_save_group = vim.api.nvim_create_augroup("AutoSaveGroup", { clear = true })

vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "AutoSaveWritePost",
    group = auto_save_group,
    callback = function()
        if package.loaded.lualine then
            require("lualine").refresh()
        end
    end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    nested = true,
    callback = function()
        if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
            vim.cmd("quit")
        end
    end,
})

vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        if vim.fn.exists(":NvimTreeRefresh") == 2 then
            vim.cmd("NvimTreeRefresh")
        end
    end,
})

local function open_nvim_tree_in_current_dir()
    local current_file = vim.fn.expand("%:p:h")
    if vim.fn.isdirectory(current_file) == 1 then
        vim.cmd("cd " .. current_file)
    end
    vim.cmd("NvimTreeToggle")
end

vim.keymap.set("n", "<leader>E", open_nvim_tree_in_current_dir, { desc = "Open file explorer in current directory" })
