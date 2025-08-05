-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("spring-boot-commands").setup()

vim.g.vim_markdown_edit_url_in = "current"
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.wo.foldlevel = 0
vim.wo.foldenable = true
