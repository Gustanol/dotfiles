return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
  },

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
      code = {
        enabled = true,
        sign = false,
        width = "block",
        right_pad = 1,
        left_pad = 1,
      },
      bullet = {
        enabled = true,
        icons = { "•", "◦", "▪", "▫" },
      },
      latex = {
        enabled = false,
      },
    },
    ft = { "markdown" },
  },
}
