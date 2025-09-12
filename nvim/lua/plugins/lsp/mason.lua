return {
    "mason-org/mason.nvim",
    dependencies = {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "jdtls",
                "lemminx", -- XML
                "yamlls",
                "jsonls",
                "dockerls",
                "docker_compose_language_service",
            },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    config = function()
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        require("mason-lspconfig").setup()

        require("mason-tool-installer").setup({
            ensure_installed = {
                -- Formatters
                "google-java-format",
                "prettier",

                -- Linters
                "checkstyle",

                -- Debug Adapters
                "java-debug-adapter",
                "java-test",

                -- Others
                "jq",
            },
            auto_update = false,
            run_on_start = true,
        })
    end,
}
