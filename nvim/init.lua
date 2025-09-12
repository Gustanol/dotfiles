-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
        os.execute("pkill -f jdtls")
    end,
})

vim.g.c_syntax_for_h = 1
vim.g.c_no_curly_error = 1
vim.opt.directory = vim.fn.expand("~/.config/nvim/swap//")
vim.opt.swapfile = true
vim.opt.updatetime = 300
--vim.g.vim_markdown_edit_url_in = "current"
--vim.wo.foldmethod = "expr"
--vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
--vim.wo.foldlevel = 0
--vim.wo.foldenable = true

vim.g.netrw_hide = 0

local java_generator = require("java-generator")

vim.api.nvim_create_user_command("JavaCreate", function()
    java_generator.create_java_interactive()
end, { desc = "Create Java file" })

local java_types = {
    "class",
    "interface",
    "enum",
    "record",
    "controller",
    "service",
    "repository",
    "entity",
    "dto",
    "test",
}

for _, type in ipairs(java_types) do
    vim.api.nvim_create_user_command("Java" .. type:gsub("^%l", string.upper), function(opts)
        local args = vim.split(opts.args, " ", { trimempty = true })
        local file_name = args[1]
        local custom_package = args[2]

        if not file_name then
            print("Usage: Java" .. type:gsub("^%l", string.upper) .. " <FileName> [package]")
            return
        end

        java_generator.create_java_file(type, file_name, custom_package)
    end, {
        nargs = "*",
        desc = "Create " .. type .. " Java",
    })
end

vim.keymap.set("n", "<leader>jc", ":JavaCreate<CR>", { desc = "Create Java file" })
vim.keymap.set("n", "<leader>jC", ":JavaClass ", { desc = "Create Java class" })
vim.keymap.set("n", "<leader>ji", ":JavaInterface ", { desc = "Create Java interface" })
vim.keymap.set("n", "<leader>js", ":JavaService ", { desc = "Create Java service" })
vim.keymap.set("n", "<leader>jr", ":JavaRepository ", { desc = "Create Java repository" })
vim.keymap.set("n", "<leader>je", ":JavaEntity ", { desc = "Create Java entity" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "c",
    callback = function()
        vim.opt_local.colorcolumn = "100"
        vim.opt_local.textwidth = 100

        vim.cmd([[
      highlight Todo guifg=#FF6C6B guibg=#1E1E1E gui=bold
      highlight Fixme guifg=#FF6C6B guibg=#1E1E1E gui=bold
      match Todo /\(TODO\|FIXME\|XXX\|HACK\|NOTE\)/
    ]])
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.c,*.h",
    callback = function()
        if vim.g.auto_format_c then
            vim.lsp.buf.format({ async = false })
        end
    end,
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "make",
    callback = function()
        vim.cmd("cwindow")
    end,
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

require("nvim-tree").setup()

require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        width = 30,
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
    },
})
