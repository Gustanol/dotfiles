return {
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
      { "<leader>E", "<cmd>NvimTreeFindFile<cr>", desc = "Explorer Find File" },
    },
    config = function()
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        view = { width = 35 },
        renderer = {
          group_empty = true,
          highlight_git = true,
        },
        filters = {
          dotfiles = true,
          custom = { "^.git$", "^node_modules$", "^target$", "^build$" },
        },
        git = { enable = true },
        actions = {
          open_file = { quit_on_open = true },
        },
      })
    end,
  },
}
