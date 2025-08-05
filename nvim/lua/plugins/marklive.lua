return {
    {
        "yelog/marklive.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        lazy = true,
        ft = "markdown",
        opts = {
            enable = true,
            show_mode = "normal-line",
            render = {
                task_list_marker_checked = { icon = "✔", highlight = { fg = "#00c900" } },
                task_list_marker_unchecked = { icon = "✗", highlight = { fg = "#777777" } },
                list_marker_minus = { icon = "-", highlight = { fg = "#444444" }, render = "list" },
                atx_h1_marker = { icon = "#", hl_group = "markdownH1Delimiter" },
            },
            highlight_config = {
                markdownBold = { highlight = { fg = "#ef9020", bold = true } },
                markdownItalic = { highlight = { fg = "#d8e020", italic = true } },
                markdownStrike = { highlight = { fg = "#939393", strikethrough = true } },
                markdownCode = { highlight = { fg = "#00c4b0", bg = "#1f262f" } },
                markdownLinkText = { highlight = { fg = "#5c92fa", underline = true } },
                markdownH1 = { highlight = { fg = "#ff6f61", bold = true } },
            },
        },
        config = function(_, opts)
            require("marklive").setup(opts)
            vim.keymap.set(
                "n",
                "<leader>lm",
                ":MarkliveToggle<CR>",
                { silent = true, desc = "Toggle Markdown preview" }
            )
        end,
    },
}
