return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "antoinemadec/FixCursorHold.nvim",
        "rcasia/neotest-java",
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-java")({
                    ignore_wrapper = false,
                }),
            },
            discovery = {
                enabled = false,
            },
            running = {
                concurrent = true,
            },
            summary = {
                enabled = true,
                animated = true,
                follow = true,
                expand_errors = true,
            },
            icons = {
                child_indent = "│",
                child_prefix = "├",
                collapsed = "─",
                expanded = "╮",
                failed = "✖",
                final_child_indent = " ",
                final_child_prefix = "╰",
                non_collapsible = "─",
                passed = "✓",
                running = "󰑮",
                running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                skipped = "○",
                unknown = "?",
            },
            floating = {
                border = "rounded",
                max_height = 0.6,
                max_width = 0.6,
                options = {},
            },
            strategies = {
                integrated = {
                    height = 40,
                    width = 120,
                },
            },
        })
    end,
    keys = {
        {
            "<leader>tr",
            function()
                require("neotest").run.run()
            end,
            desc = "Run nearest test",
        },
        {
            "<leader>tf",
            function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
            desc = "Run current file",
        },
        {
            "<leader>tT",
            function()
                require("neotest").run.run({ suite = true })
            end,
            desc = "Run test suite",
        },
        {
            "<leader>ts",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "Toggle test summary",
        },
        {
            "<leader>to",
            function()
                require("neotest").output_panel.toggle()
            end,
            desc = "Toggle test output",
        },
    },
}
