return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "java", "c" },
        highlight = {
          enable = true, -- Enable highlighting
        },
        indent = {
          enable = true, -- Enable indentation
        },
      })
    end,
  },
}

