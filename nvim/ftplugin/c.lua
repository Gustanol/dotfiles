vim.opt_local.cindent = true
vim.opt_local.cinoptions = ":0,l1,t0,g0,(0"
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

vim.opt_local.showmatch = true

vim.opt_local.makeprg = "gcc -Wall -Wextra -std=c11 -g -o %< %"

local keymap = vim.keymap.set
local opts = { buffer = true, silent = true }

keymap("n", "<leader>cc", function()
    vim.cmd("make")
end, vim.tbl_extend("force", opts, { desc = "Compile C file" }))

keymap("n", "<leader>cr", function()
    local filename = vim.fn.expand("%:r")
    vim.cmd("!" .. filename)
end, vim.tbl_extend("force", opts, { desc = "Run compiled C program" }))

keymap("n", "<leader>cx", function()
    vim.cmd("make")
    local filename = vim.fn.expand("%:r")
    vim.cmd("!" .. filename)
end, vim.tbl_extend("force", opts, { desc = "Compile and run C program" }))

keymap("n", "<leader>ch", function()
    local current_file = vim.fn.expand("%:p")
    local extension = vim.fn.expand("%:e")
    local filename = vim.fn.expand("%:r")

    local target_file
    if extension == "c" then
        target_file = filename .. ".h"
    elseif extension == "h" then
        target_file = filename .. ".c"
    end

    if target_file and vim.fn.filereadable(target_file) == 1 then
        vim.cmd("edit " .. target_file)
    else
        print("Header/source file not found")
    end
end, vim.tbl_extend("force", opts, { desc = "Toggle between header and source" }))

keymap("n", "<leader>cd", function()
    local filename = vim.fn.expand("%:r")
    vim.cmd("!gcc -g -o " .. filename .. " " .. vim.fn.expand("%"))
    vim.cmd("!gdb " .. filename)
end, vim.tbl_extend("force", opts, { desc = "Compile and debug with GDB" }))

if vim.lsp.get_active_clients({ name = "clangd" })[1] then
    keymap(
        "n",
        "<leader>cs",
        "<cmd>ClangdSwitchSourceHeader<cr>",
        vim.tbl_extend("force", opts, { desc = "Switch source/header" })
    )
    keymap(
        "n",
        "<leader>ct",
        "<cmd>ClangdTypeHierarchy<cr>",
        vim.tbl_extend("force", opts, { desc = "Type hierarchy" })
    )
    keymap("n", "<leader>cm", "<cmd>ClangdMemoryUsage<cr>", vim.tbl_extend("force", opts, { desc = "Memory usage" }))
end

vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.h",
    callback = function()
        local filename = vim.fn.expand("%:t:r"):upper() .. "_H"
        local lines = {
            "#ifndef " .. filename,
            "#define " .. filename,
            "",
            "",
            "",
            "#endif /* " .. filename .. " */",
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.api.nvim_win_set_cursor(0, { 4, 0 })
    end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.c",
    callback = function()
        local filename = vim.fn.expand("%:t:r")
        local header_exists = vim.fn.filereadable(filename .. ".h") == 1

        local lines = {
            "#include <stdio.h>",
            "#include <stdlib.h>",
        }

        if header_exists then
            table.insert(lines, '#include "' .. filename .. '.h"')
        end

        table.insert(lines, "")
        table.insert(lines, "int main() {")
        table.insert(lines, "    ")
        table.insert(lines, "    return 0;")
        table.insert(lines, "}")

        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.api.nvim_win_set_cursor(0, { #lines - 2, 4 })
    end,
})
