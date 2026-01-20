return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    opts = {
      file_types = { "markdown" },
      heading = {
        enabled = true,
        sign = false,
        icons = { "󰲠 ", "󰲢 ", "󰲤 ", "󰲦 ", "󰲨 ", "󰲪 " },
      },
      exclude = {
        buftypes = { 'nofile' },
      },
      code = {
        enabled = true,
        sign = true,
        width = "block",
        right_pad = 1,
        left_pad = 1,
      },
      bullet = {
        enabled = true,
        icons = { "•", "◦", "▪", "▫" },
      },
    },
    ft = { "markdown" },
  },
}
