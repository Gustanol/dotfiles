return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require("dashboard").setup({
      theme = "doom",
      config = {
        header = {
          "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
          "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
          "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          "",
          "",
        },
        center = {
          {
            icon = "  ",
            desc = "Find File                        ",
            key = "f",
            action = "Telescope find_files",
          },
          {
            icon = "  ",
            desc = "New File",
            key = "n",
            action = "enew",
          },
          {
            icon = "󰍹  ",
            desc = "Projects",
            key = "p",
            action = "FindProjects",
          },
          {
            icon = "  ",
            desc = "Configuration",
            key = "c",
            action = "cd ~/projects/dotfiles/nvim/ | Telescope find_files",
          },
          {
            icon = "  ",
            desc = "Terminal",
            key = "t",
            action = "terminal",
          },
          {
            icon = "  ",
            desc = "Mason",
            key = "m",
            action = "Mason",
          },
          {
            icon = "󰒲  ",
            desc = "Lazy",
            key = "l",
            action = "Lazy",
          },
        },
        footer = {},
        vertical_center = true,
      },
    })
  end,
  dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
