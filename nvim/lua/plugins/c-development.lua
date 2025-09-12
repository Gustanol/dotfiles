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
                        "--all-scopes-completion",
                        "--cross-file-rename",
                        "--log=verbose",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                    filetypes = { "c" },
                    root_dir = function(fname)
                        local util = require("lspconfig.util")
                        return util.root_pattern(
                            "Makefile",
                            "makefile",
                            "compile_commands.json",
                            "compile_flags.txt",
                            ".git"
                        )(fname) or util.dirname(fname)
                    end,
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                },
            },
            setup = {
                clangd = function(_, opts)
                    vim.api.nvim_create_autocmd("FileType", {
                        pattern = "c",
                        callback = function(event)
                            local buf = event.buf
                            vim.bo[buf].commentstring = "/* %s */"
                            vim.bo[buf].tabstop = 4
                            vim.bo[buf].shiftwidth = 4
                            vim.bo[buf].expandtab = true
                            vim.bo[buf].cindent = true

                            local function map(mode, lhs, rhs, desc)
                                vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
                            end

                            map(
                                "n",
                                "<leader>cc",
                                ":lua require('c-commands').compile_current()<CR>",
                                "Compile Current File"
                            )
                            map("n", "<leader>cr", ":lua require('c-commands').run_current()<CR>", "Run Current File")
                            map("n", "<leader>cm", ":lua require('c-commands').make_project()<CR>", "Make Project")
                            map(
                                "n",
                                "<leader>cD",
                                ":lua require('c-commands').debug_current()<CR>",
                                "Debug Current File"
                            )
                            map("n", "<leader>ct", ":lua require('c-commands').run_tests()<CR>", "Run Tests")
                            map(
                                "n",
                                "<leader>ch",
                                ":lua require('c-commands').toggle_header_source()<CR>",
                                "Toggle Header/Source"
                            )

                            map(
                                "n",
                                "<leader>cg",
                                ":lua require('c-commands').add_include_guard()<CR>",
                                "Add Include Guard"
                            )

                            map("n", "<leader>cf", ":lua require('c-commands').find_functions()<CR>", "Find Functions")

                            map("n", "<leader>cl", ":lua require('c-commands').lint_file()<CR>", "Lint Current File")
                        end,
                    })
                end,
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "c" })
            opts.ensure_installed = vim.tbl_filter(function(lang)
                return lang ~= "cpp"
            end, opts.ensure_installed or {})
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

            if not dap.adapters.codelldb then
                require("dap").adapters.codelldb = {
                    type = "server",
                    host = "127.0.0.1",
                    port = 13000,
                    executable = {
                        command = vim.fn.exepath("codelldb"),
                        args = { "--port", "13000" },
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
                            local file = vim.fn.expand("%:t:r")
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/" .. file, "file")
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
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                c = { "clang_format" },
            },
            formatters = {
                clang_format = {
                    prepend_args = {
                        "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never, ColumnLimit: 100}",
                    },
                },
            },
        },
    },

    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                c = { "cppcheck" },
            },
        },
    },

    {
        "L3MON4D3/LuaSnip",
        opts = function(_, opts)
            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node
            local f = ls.function_node

            local c_snippets = {
                s("main", {
                    t({ "#include <stdio.h>", "", "int main() {", "    " }),
                    i(1, "// TODO: Implement"),
                    t({ "", "    return 0;", "}" }),
                }),

                s("inc", {
                    t("#include <"),
                    i(1, "stdio.h"),
                    t(">"),
                }),

                s("pf", {
                    t('printf("'),
                    i(1, "%d\\n"),
                    t('", '),
                    i(2, "variable"),
                    t(");"),
                }),

                s("for", {
                    t("for (int "),
                    i(1, "i"),
                    t(" = 0; "),
                    f(function(args)
                        return args[1][1]
                    end, { 1 }),
                    t(" < "),
                    i(2, "n"),
                    t("; "),
                    f(function(args)
                        return args[1][1]
                    end, { 1 }),
                    t("++) {"),
                    t({ "", "    " }),
                    i(0),
                    t({ "", "}" }),
                }),

                s("while", {
                    t("while ("),
                    i(1, "condition"),
                    t(") {"),
                    t({ "", "    " }),
                    i(0),
                    t({ "", "}" }),
                }),

                s("if", {
                    t("if ("),
                    i(1, "condition"),
                    t(") {"),
                    t({ "", "    " }),
                    i(0),
                    t({ "", "}" }),
                }),

                s("func", {
                    i(1, "int"),
                    t(" "),
                    i(2, "function_name"),
                    t("("),
                    i(3, "void"),
                    t(") {"),
                    t({ "", "    " }),
                    i(0),
                    t({ "", "}" }),
                }),

                s("struct", {
                    t("typedef struct {"),
                    t({ "", "    " }),
                    i(1, "int member;"),
                    t({ "", "} " }),
                    i(2, "StructName"),
                    t(";"),
                }),

                s("arr", {
                    i(1, "int"),
                    t(" "),
                    i(2, "array"),
                    t("["),
                    i(3, "SIZE"),
                    t("];"),
                }),
            }

            ls.add_snippets("c", c_snippets)
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        opts = {
            defaults = {
                file_ignore_patterns = {
                    "%.o$",
                    "%.out$",
                    "%.exe$",
                    "%.a$",
                    "%.so$",
                    "%.dll$",
                    "%.dylib$",
                    "core",
                    "a%.out",
                },
            },
        },
    },

    {
        "nvim-telescope/telescope-project.nvim",
        config = function()
            vim.api.nvim_create_user_command("CCreateProject", function()
                require("c-commands").create_c_project()
            end, { desc = "Create new C project" })
        end,
    },
}
