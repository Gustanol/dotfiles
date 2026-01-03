return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- Formatters
        "shfmt", -- Shell
        "clang-format",

        -- LSPs
        "ccls",
        "lua-language-server", -- Lua
      },
      auto_update = true,
      run_on_start = true,
    })
  end,
}
