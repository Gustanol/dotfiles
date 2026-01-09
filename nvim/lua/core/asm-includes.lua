local M = {}

-- Get project include directories based on .nvim-project.json
M.get_project_includes = function()
  local project_config = require("core.project-config")
  local config, config_dir = project_config.get_buffer_config()

  if not config or not config_dir then
    return {}
  end

  local includes = {}

  if config.project_type == "linux_kernel" then
    table.insert(includes, config_dir .. "/include")
    table.insert(includes, config_dir .. "/arch/x86/include")
    table.insert(includes, config_dir .. "/arch/x86/include/generated")
  elseif config.project_type == "linux_module" then
    local kernel_headers = "~/qemu-lab/linux-6.17.8/"
    if vim.fn.isdirectory(kernel_headers) == 1 then
      table.insert(includes, kernel_headers .. "/include")
      table.insert(includes, kernel_headers .. "/arch/x86/include")
    end
  elseif config.project_type == "custom" then
    -- For custom projects, scan for include directories
    if vim.fn.isdirectory(config_dir .. "/include") == 1 then
      table.insert(includes, config_dir .. "/include")
    end
    if vim.fn.isdirectory(config_dir .. "/arch/x86/include") == 1 then
      table.insert(includes, config_dir .. "/arch/x86/include")
    end
  end

  return includes
end

-- Resolve include path for gf command
M.resolve_include = function(fname)
  local clean_fname = fname:gsub("^<", ""):gsub(">$", ""):gsub("^\"", ""):gsub("\"$", "")

  -- Try project includes first
  local includes = M.get_project_includes()
  for _, include_dir in ipairs(includes) do
    local full_path = include_dir .. "/" .. clean_fname
    if vim.fn.filereadable(full_path) == 1 then
      return full_path
    end
  end

  -- Fallback to relative path
  return clean_fname
end

-- Setup assembly file settings
M.setup = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "asm", "nasm", "gas" },
    callback = function(ev)
      local includes = M.get_project_includes()

      -- Set include paths for gf
      vim.opt_local.path = vim.opt_local.path + includes
      vim.opt_local.includeexpr = [[v:lua.require('core.asm-includes').resolve_include(v:fname)]]

      -- Match #include and .include directives
      vim.opt_local.include = [[^\s*\(#\s*include\|\.include\)]]

      -- Assembly formatting
      vim.opt_local.expandtab = false
      vim.opt_local.tabstop = 8
      vim.opt_local.shiftwidth = 8
      vim.opt_local.softtabstop = 8
      vim.opt_local.commentstring = "# %s"

      -- Better folding
      vim.opt_local.foldmethod = "marker"
      vim.opt_local.foldmarker = "{{{,}}}"
    end,
  })
end

return M
