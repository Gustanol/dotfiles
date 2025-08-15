-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("spring-boot-commands").setup()
require("microservices").setup()

vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
        os.execute("pkill -f jdtls")
    end,
})

vim.g.c_syntax_for_h = 1
vim.g.c_no_curly_error = 1

--vim.g.vim_markdown_edit_url_in = "current"
--vim.wo.foldmethod = "expr"
--vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
--vim.wo.foldlevel = 0
--vim.wo.foldenable = true

local java_generator = require("java-generator")

vim.api.nvim_create_user_command("JavaCreate", function()
    java_generator.create_java_interactive()
end, { desc = "Criar arquivo Java interativamente" })

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
        desc = "Criar " .. type .. " Java",
    })
end

vim.keymap.set("n", "<leader>jc", ":JavaCreate<CR>", { desc = "Criar arquivo Java" })
vim.keymap.set("n", "<leader>jC", ":JavaClass ", { desc = "Criar classe Java" })
vim.keymap.set("n", "<leader>ji", ":JavaInterface ", { desc = "Criar interface Java" })
vim.keymap.set("n", "<leader>js", ":JavaService ", { desc = "Criar service Java" })
vim.keymap.set("n", "<leader>jr", ":JavaRepository ", { desc = "Criar repository Java" })
vim.keymap.set("n", "<leader>je", ":JavaEntity ", { desc = "Criar entity Java" })

require("c-commands").setup()

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
