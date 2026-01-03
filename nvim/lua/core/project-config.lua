local M = {}

-- Default project configuration
M.default_config = {
  version = "1.0",
  project_type = "custom", -- userspace, linux_kernel, linux_module, custom
  custom_flags = {},       -- For custom project type
  include_paths = {},      -- Additional include paths
}

-- Get project config file path for a directory
M.get_config_path = function(dir)
  dir = dir or vim.fn.getcwd()
  return dir .. "/.nvim-project.json"
end

-- Load project configuration
M.load_config = function(dir)
  local config_path = M.get_config_path(dir)

  if vim.fn.filereadable(config_path) == 0 then
    return nil
  end

  local file = io.open(config_path, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  local ok, config = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Invalid .nvim-project.json: " .. config, vim.log.levels.ERROR)
    return nil
  end

  return vim.tbl_deep_extend("force", M.default_config, config)
end

-- Save project configuration
M.save_config = function(config, dir)
  local config_path = M.get_config_path(dir)

  local file = io.open(config_path, "w")
  if not file then
    vim.notify("Failed to create .nvim-project.json", vim.log.levels.ERROR)
    return false
  end

  local json = vim.json.encode(config)
  file:write(json)
  file:close()

  vim.notify("Created: " .. config_path, vim.log.levels.INFO)
  return true
end

-- Find the nearest project config by walking up the directory tree
M.find_nearest_config = function(start_path)
  start_path = start_path or vim.fn.expand("%:p:h")

  -- Normalize path
  start_path = vim.fn.fnamemodify(start_path, ":p")

  local current = start_path
  local root = "/"

  while current ~= root do
    local config_path = current .. "/.nvim-project.json"
    if vim.fn.filereadable(config_path) == 1 then
      local config = M.load_config(current)
      if config then
        return config, current
      end
    end

    local parent = vim.fn.fnamemodify(current, ":h")
    if parent == current then
      break
    end
    current = parent
  end

  return nil, nil
end

-- Cache config per buffer to avoid re-detection
M.get_buffer_config = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if already cached
  if vim.b[bufnr].project_config and vim.b[bufnr].project_config_dir then
    return vim.b[bufnr].project_config, vim.b[bufnr].project_config_dir
  end

  -- Find and cache
  local buffer_path = vim.api.nvim_buf_get_name(bufnr)
  if buffer_path == "" then
    return nil, nil
  end

  local buffer_dir = vim.fn.fnamemodify(buffer_path, ":p:h")
  local config, config_dir = M.find_nearest_config(buffer_dir)

  if config then
    vim.b[bufnr].project_config = config
    vim.b[bufnr].project_config_dir = config_dir
  end

  return config, config_dir
end

-- Extract compiler flags from Makefile
M.extract_makefile_flags = function(dir)
  dir = dir or vim.fn.getcwd()
  local makefile = dir .. "/Makefile"

  if vim.fn.filereadable(makefile) == 0 then
    return {}
  end

  local flags = {}
  local file = io.open(makefile, "r")
  if not file then
    return flags
  end

  local function expand_vars(str, vars)
    return (str:gsub("%$%(([%w_]+)%)", function(var)
      return vars[var] or ""
    end))
  end

  local vars = {}
  for line in file:lines() do
    local name, value = line:match("^%s*([%w_]+)%s*[:+]?=%s*(.+)")
    if name and value then
      vars[name] = value
    end

    local cflags = line:match("CFLAGS%s*[+:]*=%s*(.+)")

    if cflags then
      cflags = expand_vars(cflags, vars)
      for flag in cflags:gmatch("%S+") do
        if flag:match("^%-") then
          table.insert(flags, flag)
        end
      end
    end
  end

  file:close()
  return flags
end

return M
