return {
  'nvim-telescope/telescope.nvim', branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = "Telescope",
  keys = {
     { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
     { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
     { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Open buffers" },
     { "<leader>fp", "<cmd>FindProjects<cr>", desc = "Projects" },
  },
}
