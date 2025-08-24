return {
    "RaafatTurki/hex.nvim",
    event = "VeryLazy", -- or use ft = {"bin", "exe"} for specific filetypes
    config = function()
        require("hex").setup({
            is_file_binary_pre_read = function(binary_ext)
                return binary_ext
            end,
            dump_cmd = "xxd -g 1 -u",
            assemble_cmd = "xxd -r",
        })
    end,

    keys = {
        { "<leader>hx", "<cmd>HexToggle<cr>", desc = "Toggle Hex View" },
        { "<leader>hd", "<cmd>HexDump<cr>", desc = "Hex Dump" },
        { "<leader>ha", "<cmd>HexAssemble<cr>", desc = "Hex Assemble" },
    },
}
