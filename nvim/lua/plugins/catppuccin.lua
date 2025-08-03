return {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
        flavour = "mocha",
        transparent_background = true,
        integrations = {
            treesitter = true,
            cmp = true,
            gitsigns = true,
            telescope = true,
            which_key = true,
            lsp_trouble = true,
            dap = true,
        },
    },
}
