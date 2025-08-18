vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.showbreak = "↳ "
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ""

vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append("t")
vim.opt_local.formatoptions:append("c")
vim.opt_local.formatoptions:append("r")
vim.opt_local.formatoptions:append("o")
vim.opt_local.formatoptions:append("q")
vim.opt_local.formatoptions:append("n")
vim.opt_local.formatoptions:append("j")

vim.opt_local.spell = true
vim.opt_local.spelllang = { "pt_br", "en_us" }

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.expandtab = true

local map = vim.keymap.set
local opts = { buffer = true, silent = true }

map(
    "n",
    "<leader>mp",
    "<cmd>MarkdownPreviewToggle<cr>",
    vim.tbl_extend("force", opts, { desc = "Toggle Markdown Preview" })
)

map("n", "<leader>ml", function()
    local word = vim.fn.expand("<cword>")
    local link = string.format("[%s](%s.md)", word, word:lower():gsub("%s+", "-"))
    vim.cmd("normal! ciw" .. link)
end, vim.tbl_extend("force", opts, { desc = "Create Link from Word" }))

map("n", "<leader>mx", function()
    local line = vim.api.nvim_get_current_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]

    if line:match("^%s*- %[ %]") then
        -- Unchecked -> Checked
        line = line:gsub("^(%s*- )%[ %]", "%1[x]")
    elseif line:match("^%s*- %[x%]") then
        -- Checked -> Unchecked
        line = line:gsub("^(%s*- )%[x%]", "%1[ ]")
    elseif line:match("^%s*- ") then
        -- Regular list -> Unchecked
        line = line:gsub("^(%s*- )", "%1[ ] ")
    else
        -- Regular line -> Unchecked list
        line = "- [ ] " .. line
    end

    vim.api.nvim_set_current_line(line)
end, vim.tbl_extend("force", opts, { desc = "Toggle Checkbox" }))

map("n", "<leader>md", function()
    local date = os.date("%Y-%m-%d")
    vim.api.nvim_put({ date }, "c", true, true)
end, vim.tbl_extend("force", opts, { desc = "Insert Current Date" }))

map("n", "<leader>mn", function()
    local title = vim.fn.input("Título: ")
    if title ~= "" then
        local date = os.date("%Y-%m-%d")
        local filename = string.format("%s_%s.md", date, title:lower():gsub("%s+", "_"))
        vim.cmd("edit " .. filename)

        local template = {
            "# " .. title,
            "",
            "Data: " .. date,
            "",
            "## Notas",
            "",
            "",
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
        vim.api.nvim_win_set_cursor(0, { #template, 0 })
    end
end, vim.tbl_extend("force", opts, { desc = "Create New Note" }))

map("n", "gj", function()
    vim.cmd("normal! /^#\\+<cr>")
end, vim.tbl_extend("force", opts, { desc = "Next Heading" }))

map("n", "gk", function()
    vim.cmd("normal! ?^#\\+<cr>")
end, vim.tbl_extend("force", opts, { desc = "Previous Heading" }))

map("n", "<leader>mt", function()
    vim.cmd("normal! vip:!column -t -s '|' -o '|'<cr>")
end, vim.tbl_extend("force", opts, { desc = "Format Table" }))

map("n", "<leader>mc", function()
    local callouts = {
        "note",
        "tip",
        "important",
        "warning",
        "caution",
    }

    vim.ui.select(callouts, {
        prompt = "Selecione o tipo de callout:",
    }, function(choice)
        if choice then
            local template = {
                "",
                "> [!" .. choice:upper() .. "]",
                "> Conteúdo do callout aqui",
                "",
            }
            local row = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_buf_set_lines(0, row, row, false, template)
            vim.api.nvim_win_set_cursor(0, { row + 3, 2 })
        end
    end)
end, vim.tbl_extend("force", opts, { desc = "Insert Callout" }))

local group = vim.api.nvim_create_augroup("MarkdownConfig", { clear = true })

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = 0,
    callback = function()
        if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
            vim.cmd("silent! write")
        end
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    buffer = 0,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    buffer = 0,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

local function generate_toc()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local toc = {}

    for i, line in ipairs(lines) do
        local level, title = line:match("^(#+)%s+(.+)")
        if level and title then
            local indent = string.rep("  ", #level - 1)
            local anchor = title:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-")
            table.insert(toc, string.format("%s- [%s](#%s)", indent, title, anchor))
        end
    end

    if #toc > 0 then
        table.insert(toc, 1, "## Índice")
        table.insert(toc, 2, "")
        table.insert(toc, "")

        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_buf_set_lines(0, cursor_pos[1] - 1, cursor_pos[1] - 1, false, toc)
    end
end

map("n", "<leader>mT", generate_toc, vim.tbl_extend("force", opts, { desc = "Generate Table of Contents" }))
