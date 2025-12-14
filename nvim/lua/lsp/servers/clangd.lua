local lsp = require("lsp.config")

require("lspconfig").clangd.setup({
  capabilities = lsp.capabilities,
  on_attach = lsp.on_attach,

  cmd = {
    "clangd",
    "--query-driver=/usr/sbin/gcc,/usr/bin/gcc",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders=true",
    "--fallback-style=llvm",
    "--log=error",
  },

  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },

  filetypes = { "c", "h", "cpp", "objc", "objcpp" },
})
