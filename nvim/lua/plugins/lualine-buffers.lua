return {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
        opts.tabline = {
            lualine_a = {
                {
                    "buffers",
                    show_filename_only = true,
                    hide_filename_extension = false,
                    show_modified_status = true,

                    mode = 0,

                    max_length = vim.o.columns * 2 / 3,
                    filetype_names = {
                        TelescopePrompt = "Telescope",
                        dashboard = "Dashboard",
                        packer = "Packer",
                        fzf = "FZF",
                        alpha = "Alpha",
                    },

                    symbols = {
                        modified = " ●",
                        alternate_file = "#",
                        directory = "",
                    },
                },
            },
            lualine_b = {},
            lualine_c = {
                {
                    "diagnostics",
                    sources = { "nvim_diagnostic" },
                    symbols = { error = " ", warn = " ", info = " " },
                },
            },
            lualine_x = {},
            lualine_y = {},
            lualine_z = {
                {
                    "tabs",
                    max_length = vim.o.columns / 3,
                    mode = 0,
                    tabs_color = {
                        active = "lualine_a_normal",
                        inactive = "lualine_a_inactive",
                    },
                },
            },
        }
        return opts
    end,
}
