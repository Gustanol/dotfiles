return {
    {
        "jghauser/follow-md-links.nvim",
        config = function()
            vim.keymap.set("n", "<CR>", function()
                vim.cmd("FollowMarkdownLink")
            end, {
                silent = true,
                buffer = true,
                desc = "Follow Markdown link (no split)",
            })
            vim.keymap.set("n", "<BS>", "<cmd>edit #<CR>", {
                silent = true,
                buffer = true,
                desc = "Voltar arquivo anterior",
            })
        end,
    },
}
