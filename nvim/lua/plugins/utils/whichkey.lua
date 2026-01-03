return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    spec = {
      { "<leader>t",  group = "Telescope" },
      { "<leader>a",  group = "Assembly" },
      { "<leader>L",  group = "Linting" },
      { "<leader>d",  group = "Diagnostics" },
      { "<leader>n",  group = "Notifications" },
      { "<leader>l",  group = "LSP" },
      { "<leader>lg", group = "'Go to' keymaps" },
      { "<leader>lw", group = "Workspace keymaps" },
      { "<leader>lc", group = "Code keymaps" },
      { "<leader>c",  group = "C keymaps" },
      { "<leader>m",  group = "Markdown keymaps" },
    },
  },
}
