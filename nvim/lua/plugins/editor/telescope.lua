return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
  },
  cmd = "Telescope",
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
      },
      extensions = {
        file_browser = {},
      },
    })
    telescope.load_extension("file_browser")
    telescope.load_extension("fzf")
  end,
  keys = {
    { "<leader>tf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>tg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
    { "<leader>tb", "<cmd>Telescope buffers<cr>", desc = "Open buffers" },
    { "<leader>tp", "<cmd>Telescope projects<cr>", desc = "Projects" },
    { "<leader>e", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },
    { "<leader>td", "<cmd>bdelete<cr>", desc = "Delete current buffer" },
    { "<leader>tc", "<cmd>close<cr>", desc = "Close window" },
    { "<leader>tt", "<cmd>terminal<cr>", desc = "Open terminal" },
  },
}
