return {
  {
    "shirk/vim-gas",
    ft = { "asm", "s", "S" },
  },

  {
    "https://github.com/Shirk/vim-gas",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "asm", "s", "S" },
        callback = function()
          vim.opt_local.expandtab = false
          vim.opt_local.tabstop = 8
          vim.opt_local.shiftwidth = 8
          vim.opt_local.commentstring = "# %s"

          vim.opt_local.path:append("./include")
          vim.opt_local.path:append("./arch/x86/include")

          vim.opt_local.include = [[^\s*\.include]]
          vim.opt_local.define = [[^\s*\.macro]]
        end,
      })
    end,
  },
}
