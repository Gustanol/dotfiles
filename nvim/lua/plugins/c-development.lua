return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                        "--compile-commands-dir=.",
                        "--query-driver=/usr/bin/gcc,/usr/bin/clang",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                    filetypes = { "c" },
                    root_dir = function(fname)
                        return require("lspconfig.util").root_pattern(
                            "compile_commands.json",
                            "compile_flags.txt",
                            ".clangd",
                            "Makefile",
                            "makefile"
                        )(fname) or require("lspconfig.util").find_git_ancestor(fname) or vim.fn.getcwd()
                    end,
                },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "c", "make", "cmake" })
            end
        end,
    },

    {
        "mfussenegger/nvim-dap",
        optional = true,
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = function(_, opts)
                    opts.ensure_installed = opts.ensure_installed or {}
                    vim.list_extend(opts.ensure_installed, { "codelldb" })
                end,
            },
        },
        opts = function()
            local dap = require("dap")
            if not dap.adapters["codelldb"] then
                require("dap").adapters["codelldb"] = {
                    type = "server",
                    host = "127.0.0.1",
                    port = 13000,
                    executable = {
                        command = "codelldb",
                        args = {
                            "--port",
                            "13000",
                        },
                    },
                }
            end
            for _, lang in ipairs({ "c" }) do
                dap.configurations[lang] = {
                    {
                        type = "codelldb",
                        request = "launch",
                        name = "Launch file",
                        program = function()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                        end,
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "codelldb",
                        request = "attach",
                        name = "Attach to process",
                        processId = require("dap.utils").pick_process,
                        cwd = "${workspaceFolder}",
                    },
                }
            end
        end,
    },

    {
        "p00f/clangd_extensions.nvim",
        lazy = true,
        config = function() end,
        opts = {
            inlay_hints = {
                inline = false,
            },
            ast = {
                role_icons = {
                    type = "",
                    declaration = "",
                    expression = "",
                    specifier = "",
                    statement = "",
                    ["template argument"] = "",
                },
                kind_icons = {
                    Compound = "",
                    Recovery = "",
                    TranslationUnit = "",
                    PackExpansion = "",
                    TemplateTypeParm = "",
                    TemplateTemplateParm = "",
                    TemplateParamObject = "",
                },
            },
        },
    },

    {
        "Civitasv/cmake-tools.nvim",
        lazy = true,
        init = function()
            local loaded = false
            local function check()
                local cwd = vim.uv.cwd()
                if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
                    require("lazy").load({ plugins = { "cmake-tools.nvim" } })
                    loaded = true
                end
            end
            check()
            vim.api.nvim_create_autocmd("DirChanged", {
                callback = function()
                    if not loaded then
                        check()
                    end
                end,
            })
        end,
        opts = {},
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "make" })
            end
        end,
    },

    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        opts = {},
    },

    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                c = { "clang_format" },
            },
            formatters = {
                clang_format = {
                    args = {
                        "--style={BasedOnStyle: llvm, IndentWidth: 4, ColumnLimit: 100}",
                    },
                },
            },
        },
    },

    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, {
                "clangd",
                "clang-format",
                "codelldb",
            })
        end,
    },
}
