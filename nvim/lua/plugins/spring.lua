return {
    {
        "elmcgill/springboot-nvim",
        dependencies = {
            "mfussenegger/nvim-jdtls",
            "neovim/nvim-lspconfig",
        },
        ft = { "java" },
        config = function()
            require("springboot-nvim").setup({
                jdtls_name = "jdtls",
                log_level = vim.log.levels.INFO,
            })
        end,
    },
    {
        "mfussenegger/nvim-jdtls",
        ft = { "java" },
        event = "VeryLazy",
    },
}
