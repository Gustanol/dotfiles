return {
    {
        "preservim/vim-markdown",
        ft = "markdown",
        dependencies = { "godlygeek/tabular" },
        config = function()
            vim.g.vim_markdown_folding_disabled = 0
            vim.g.vim_markdown_folding_style_pythonic = 1
            vim.g.vim_markdown_toc_autofit = 1
            vim.g.vim_markdown_conceal = 1
            vim.o.conceallevel = 2
        end,
    },
    {
        "ellisonleao/glow.nvim",
        ft = "markdown",
        cmd = { "Glow" },
        config = function()
            require("glow").setup({
                width = 80,
                style = "auto",
            })
        end,
    },
}
