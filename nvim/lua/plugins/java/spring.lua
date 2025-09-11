return {
    {
        "elmcgill/springboot-nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-jdtls",
        },
        config = function()
            local springboot_nvim = require("springboot-nvim")
            springboot_nvim.setup({})
        end,
    },

    {
        "rest-nvim/rest.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("rest-nvim").setup({
                result_split_horizontal = false,
                result_split_in_place = false,
                skip_ssl_verification = false,
                encode_url = true,
                highlight = {
                    enabled = true,
                    timeout = 150,
                },
                result = {
                    show_url = true,
                    show_http_info = true,
                    show_headers = true,
                    formatters = {
                        json = "jq",
                        html = function(body)
                            return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
                        end,
                    },
                },
                jump_to_request = false,
                env_file = ".env",
                custom_dynamic_variables = {},
                yank_dry_run = true,
            })
        end,
        ft = "http",
    },
}
