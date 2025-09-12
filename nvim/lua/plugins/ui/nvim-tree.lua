return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            sync_root_with_cwd = true,
            respect_buf_cwd = true,

            update_focused_file = {
                enable = false,
                update_cwd = false,
                ignore_list = {},
            },

            system_open = {
                cmd = nil,
                args = {},
            },

            diagnostics = {
                enable = false,
                show_on_dirs = false,
                icons = {
                    hint = "",
                    info = "",
                    warning = "",
                    error = "",
                },
            },

            renderer = {
                root_folder_label = ":~:s?$?/..?",
                highlight_git = true,
                icons = {
                    show = {
                        git = true,
                        folder = true,
                        file = true,
                        folder_arrow = true,
                    },
                },
            },

            filters = {
                dotfiles = false,
                custom = {},
                exclude = {},
            },

            git = {
                enable = true,
                ignore = true,
                timeout = 400,
            },

            hijack_directories = {
                enable = true,
                auto_open = true,
            },

            actions = {
                change_dir = {
                    enable = true,
                    global = false,
                },
                open_file = {
                    quit_on_open = false,
                    resize_window = false,
                    window_picker = {
                        enable = true,
                    },
                },
            },
        })
    end,
}
