local M = {}

-- Default project configuration
M.default_config = {
  version = "1.0",
  project_type = "userspace",
}

-- Get .ccls file path
M.get_ccls_path = function(dir)
  dir = dir or vim.fn.getcwd()
  return dir .. "/.ccls"
end

-- Get project config file path
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

-- Save project configuration (simplified - only stores type)
M.save_config = function(config, dir)
  local config_path = M.get_config_path(dir)

  local file = io.open(config_path, "w")
  if not file then
    vim.notify("Failed to create .nvim-project.json", vim.log.levels.ERROR)
    return false
  end

  -- Only store project type - flags go in .ccls
  local simple_config = {
    version = "1.0",
    project_type = config.project_type,
  }

  local json = vim.json.encode(simple_config)
  file:write(json)
  file:close()

  vim.notify("Created: " .. config_path, vim.log.levels.INFO)
  return true
end

-- Generate .ccls file from project type
M.generate_ccls = function(project_type, dir)
  dir = dir or vim.fn.getcwd()
  local ccls_path = M.get_ccls_path(dir)

  local file = io.open(ccls_path, "w")
  if not file then
    vim.notify("Failed to create .ccls", vim.log.levels.ERROR)
    return false
  end

  file:write("clang\n\n")

  if project_type == "linux_kernel" then
    file:write("# Linux Kernel Source Tree\n")
    file:write("-nostdinc\n")
    file:write("-D__KERNEL__\n")
    file:write("-DCONFIG_X86_64\n")
    file:write("-I%h/arch/x86/include\n")
    file:write("-I%h/arch/x86/include/generated\n")
    file:write("-I%h/include\n")
    file:write("-I%h/arch/x86/include/uapi\n")
    file:write("-I%h/include/uapi\n")
  elseif project_type == "linux_module" then
    local kernel_release = vim.fn.system("uname -r"):gsub("\n", "")
    local kernel_headers = "/lib/modules/" .. kernel_release .. "/build"

    file:write("# Linux Kernel Module\n")
    file:write("-nostdinc\n")
    file:write("-D__KERNEL__\n")
    file:write("-DMODULE\n")
    file:write("-DCONFIG_X86_64\n")
    file:write(string.format("-I%s/arch/x86/include\n", kernel_headers))
    file:write(string.format("-I%s/arch/x86/include/generated\n", kernel_headers))
    file:write(string.format("-I%s/include\n", kernel_headers))
    file:write(string.format("-I%s/arch/x86/include/uapi\n", kernel_headers))
    file:write(string.format("-I%s/include/uapi\n", kernel_headers))
  elseif project_type == "custom" then
    -- Try to extract from Makefile.flags
    local flags = M.extract_makefile_flags(dir)
    for _, flag in ipairs(flags) do
      -- Convert absolute paths to %h relative
      file:write(flag .. "\n")
    end

    -- Defaults if no Makefile.flags
    if #flags == 0 then
      file:write("-I./include\n")
    end
  else -- userspace
    file:write("# Userspace Project\n")
    -- Let CCLS use system defaults
  end

  file:close()

  vim.notify("Created: " .. ccls_path, vim.log.levels.INFO)
  return true
end

-- Extract compiler flags from Makefile.flags (keep this)
M.extract_makefile_flags = function(dir)
  dir = dir or vim.fn.getcwd()

  local flags_file = dir .. "/Makefile.flags"
  local makefile = dir .. "/Makefile"

  local file_to_read = vim.fn.filereadable(flags_file) == 1 and flags_file or
      vim.fn.filereadable(makefile) == 1 and makefile or nil

  if not file_to_read then
    return {}
  end

  local flags = {}
  local file = io.open(file_to_read, "r")
  if not file then
    return flags
  end

  local continued_line = ""

  for line in file:lines() do
    line = line:gsub("#.*$", "")

    if line:match("\\%s*$") then
      continued_line = continued_line .. line:gsub("\\%s*$", " ")
      goto continue
    else
      line = continued_line .. line
      continued_line = ""
    end

    local var_name, value = line:match("^%s*([A-Z_]+)%s*[+:]?=%s*(.*)$")

    if var_name and (var_name == "CFLAGS" or var_name == "ASFLAGS") then
      for flag in value:gmatch("%S+") do
        if flag:match("^%-") then
          if flag:match("^%-I") then
            local path = flag:sub(3)
            if path:match("^%./") then
              path = dir .. path:sub(3)
            elseif not path:match("^/") then
              path = dir .. path
            end
            table.insert(flags, "-I" .. path)
          else
            table.insert(flags, flag)
          end
        end
      end
    end

    ::continue::
  end

  file:close()

  if #flags == 0 and vim.fn.isdirectory(dir .. "/include") == 1 then
    flags = {
      "-nostdinc",
      "-ffreestanding",
      "-fno-builtin",
      "-I" .. dir .. "/include",
      "-D__KERNEL__",
    }
  end

  return flags
end

-- Find nearest .ccls or .nvim-project.json
M.find_nearest_config = function(start_path)
  start_path = start_path or vim.fn.expand("%:p:h")
  start_path = vim.fn.fnamemodify(start_path, ":p")

  local current = start_path
  local root = "/"

  while current ~= root do
    -- Check for .ccls first (higher priority)
    local ccls_path = current .. "/.ccls"
    if vim.fn.filereadable(ccls_path) == 1 then
      local config = M.load_config(current) or { project_type = "custom" }
      return config, current
    end

    -- Then check for .nvim-project.json
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

-- Cache config per buffer
M.get_buffer_config = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.b[bufnr].project_config and vim.b[bufnr].project_config_dir then
    return vim.b[bufnr].project_config, vim.b[bufnr].project_config_dir
  end

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

return M
