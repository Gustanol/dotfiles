local M = {}
local project_config = require("core.project-config")

-- Get kernel headers path
local function get_kernel_headers_path()
  local kernel_release = vim.fn.system("uname -r"):gsub("\n", "")
  local paths = {
    "~/qemu-lab/linux-6.17.8/",
    "/lib/modules/" .. kernel_release .. "/build",
    "/usr/src/linux-headers-" .. kernel_release,
    "/usr/src/kernels/" .. kernel_release,
  }

  for _, path in ipairs(paths) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end

  return nil
end

-- Extract include paths from Makefile with variable expansion
local function get_makefile_includes()
  local makefile = vim.fn.getcwd() .. "/Makefile"
  if vim.fn.filereadable(makefile) == 0 then
    return {}
  end

  local includes = {}
  local variables = {}
  local content = vim.fn.readfile(makefile)

  -- First pass: collect variable definitions
  for _, line in ipairs(content) do
    line = line:gsub("#.*$", "")
    local var_name, var_value = line:match("^([%w_]+)%s*[:=]%s*(.+)$")
    if var_name and var_value then
      variables[var_name] = var_value:gsub("%s+$", "")
    end
  end

  -- Function to expand variables
  local function expand_vars(str, depth)
    if depth > 10 then return str end

    local expanded = str:gsub("%$%(([%w_]+)%)", function(var)
      return variables[var] or ""
    end)

    expanded = expanded:gsub("%${([%w_]+)}", function(var)
      return variables[var] or ""
    end)

    if expanded:match("%$[%({]") then
      return expand_vars(expanded, depth + 1)
    end

    return expanded
  end

  -- Second pass: find -I flags
  for _, line in ipairs(content) do
    line = line:gsub("#.*$", "")
    line = expand_vars(line, 0)

    for flag in line:gmatch("-I%s*([^%s]+)") do
      local path = flag

      if not vim.startswith(path, "/") then
        path = vim.fn.getcwd() .. "/" .. path
      end

      path = vim.fn.resolve(path)

      if vim.fn.isdirectory(path) == 1 then
        table.insert(includes, path)
      end
    end
  end

  -- Remove duplicates
  local seen = {}
  local unique_includes = {}
  for _, inc in ipairs(includes) do
    if not seen[inc] then
      seen[inc] = true
      table.insert(unique_includes, inc)
    end
  end

  return unique_includes
end

-- Get project include directories based on config
M.get_project_includes = function()
  local includes = {}
  local cwd = vim.fn.getcwd()
  local config = project_config.read_config()
  local project_type = config and config.project_type or "userspace"

  if project_type == "linux_kernel" then
    local dirs = {
      cwd .. "/include",
      cwd .. "/arch/x86/include",
      cwd .. "/arch/x86/include/generated",
    }
    for _, dir in ipairs(dirs) do
      if vim.fn.isdirectory(dir) == 1 then
        table.insert(includes, dir)
      end
    end
  elseif project_type == "kernel_module" then
    local kernel_headers = get_kernel_headers_path()
    if kernel_headers then
      table.insert(includes, kernel_headers .. "/include")
      table.insert(includes, kernel_headers .. "/arch/x86/include")
      table.insert(includes, kernel_headers .. "/arch/x86/include/generated")
    end
  elseif project_type == "makefile_based" then
    includes = get_makefile_includes()
  end

  return includes
end

-- Setup assembly file includes
M.setup = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "asm", "s", "S" },
    callback = function()
      local includes = M.get_project_includes()

      vim.opt_local.path = vim.opt_local.path + includes
      vim.opt_local.includeexpr = [[v:lua.require('core.asm-includes').resolve_include(v:fname)]]
      vim.opt_local.include = [[^\s*#\s*include]]

      vim.opt_local.expandtab = false
      vim.opt_local.tabstop = 8
      vim.opt_local.shiftwidth = 8
      vim.opt_local.commentstring = "# %s"
    end,
  })
end

-- Resolve include paths
M.resolve_include = function(fname)
  local clean_fname = fname:gsub("^<", ""):gsub(">$", "")

  local includes = M.get_project_includes()
  for _, include_dir in ipairs(includes) do
    local full_path = include_dir .. "/" .. clean_fname
    if vim.fn.filereadable(full_path) == 1 then
      return full_path
    end
  end

  return clean_fname
end

return M
