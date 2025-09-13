vim.api.nvim_create_user_command(
  'FindProjects',
  function()
    require('telescope.builtin').find_files({ cwd = "~/projects/" })
  end,
  {}
)
