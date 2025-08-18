return {
    "stevearc/oil.nvim",
    opts = {
        default_file_explorer = true,
        columns = {
            "icon",
            "permissions",
            "size",
            "mtime",
        },
        view_options = {
            show_hidden = true,
            is_hidden_file = function(name, bufnr)
                return vim.startswith(name, ".")
            end,
            natural_order = true,
        },
        float = {
            padding = 2,
            max_width = 120,
            max_height = 30,
            border = "rounded",
            win_options = {
                winblend = 10,
            },
            override = function(conf)
                conf.row = math.floor(vim.o.lines * 0.15)
                conf.col = math.floor((vim.o.columns - conf.width) / 2)
                return conf
            end,
        },
        preview = {
            max_width = 0.9,
            min_width = { 40, 0.4 },
            border = "rounded",
        },
        keymaps = {
            ["<Esc>"] = "actions.close",
            ["q"] = "actions.close",
            ["<C-c>"] = "actions.close",
            ["<C-h>"] = false, -- Disable default, we'll use for window navigation
            ["<C-l>"] = false, -- Disable default
            ["H"] = "actions.toggle_hidden", -- Toggle hidden files like Neo-tree
        },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function(_, opts)
        require("oil").setup(opts)

        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        vim.api.nvim_create_autocmd("BufLeave", {
            pattern = "oil://*",
            callback = function()
                vim.defer_fn(function()
                    local oil_buffers = vim.tbl_filter(function(buf)
                        return vim.bo[buf].filetype == "oil" and vim.api.nvim_buf_is_valid(buf)
                    end, vim.api.nvim_list_bufs())

                    for _, buf in ipairs(oil_buffers) do
                        local windows = vim.fn.win_findbuf(buf)
                        if #windows == 0 then
                            vim.api.nvim_buf_delete(buf, { force = true })
                        end
                    end
                end, 100)
            end,
        })
    end,
    keys = {
        { "<leader>fe", "<cmd>Oil --float<cr>", desc = "Explorer Oil (Root Dir)" },
        {
            "<leader>fE",
            function()
                require("oil").open_float(vim.uv.cwd())
            end,
            desc = "Explorer Oil (cwd)",
        },
        { "<leader>e", "<cmd>Oil --float<cr>", desc = "Explorer Oil (Root Dir)" },
        {
            "<leader>E",
            function()
                require("oil").open_float(vim.uv.cwd())
            end,
            desc = "Explorer Oil (cwd)",
        },

        {
            "<leader>-",
            function()
                require("oil").open_float(vim.fn.expand("%:p:h"))
            end,
            desc = "Oil (current file dir)",
        },
        {
            "<leader>_",
            function()
                require("oil").open()
            end,
            desc = "Oil (buffer)",
        },
    },
}
