return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
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

        require("mason-lspconfig").setup({
            ensure_installed = {
                "jdtls",
                "lemminx", -- XML
                "yamlls",
                "jsonls",
                "dockerls",
                "docker_compose_language_service",
            },
        })

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
