return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- Linters
        "cppcheck", -- C/C++
        "eslint_d", -- JavaScript/TypeScript
        "pylint", -- Python
        "luacheck", -- Lua
        "shellcheck", -- Shell
        "yamllint", -- YAML
        "hadolint", -- Dockerfile
        "markdownlint", -- Markdown

        -- Formatters
        "clang-format", -- C/C++
        "prettier", -- JS/TS/JSON/YAML/Markdown
        "stylua", -- Lua
        "shfmt", -- Shell
        "black", -- Python

        -- LSPs
        "clangd", -- C/C++
        "lua-language-server", -- Lua
        "json-lsp", -- JSON
        "yaml-language-server", -- YAML
      },
      auto_update = true,
      run_on_start = true,
    })
  end,
}
