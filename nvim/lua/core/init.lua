-- essetials configurations
require("core.options")

-- plugin manager
require("core.lazy")

require("core.keymaps")
require("core.autocmds")

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.java",
  once = true,
  callback = function()
    require("config.java")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
  once = true,
  callback = function()
    require("config.javascript")
  end,
})
