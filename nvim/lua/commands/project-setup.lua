local M = {}
local project_config = require("core.project-config")

-- Project type options
local project_types = {
  { name = "Userspace Project",        value = "userspace" },
  { name = "Linux Kernel Source Tree", value = "linux_kernel" },
  { name = "Linux Kernel Module",      value = "linux_module" },
  { name = "Custom (Kernel-like)",     value = "custom" },
}

-- Select project type
M.select_project_type = function(callback)
  vim.ui.select(project_types, {
    prompt = "Select project type:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      callback(choice.value)
    end
  end)
end

-- Select directory
M.select_directory = function(callback)
  local current_dir = vim.fn.getcwd()

  vim.ui.input({
    prompt = "Where to save config? ",
    default = current_dir,
    completion = "dir",
  }, function(input)
    if input then
      local dir = vim.fn.fnamemodify(input, ":p")
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify("Directory does not exist: " .. dir, vim.log.levels.ERROR)
        return
      end
      callback(dir)
    end
  end)
end

-- Create project configuration
M.create_project_config = function()
  M.select_project_type(function(project_type)
    M.select_directory(function(dir)
      local config = {
        version = "1.0",
        project_type = project_type,
      }

      -- Save .nvim-project.json (just type info)
      if not project_config.save_config(config, dir) then
        return
      end

      -- Generate .ccls (actual compiler flags)
      if not project_config.generate_ccls(project_type, dir) then
        return
      end

      vim.notify("Project configured! Restart LSP to apply.", vim.log.levels.INFO)
      vim.schedule(function()
        vim.cmd("LspRestart")
      end)
    end)
  end)
end

-- Quick kernel setup
M.quick_kernel_setup = function()
  local dir = vim.fn.getcwd()

  if vim.fn.isdirectory(dir .. "/include") == 0 then
    vim.notify("No include/ directory found. Create it first.", vim.log.levels.WARN)
    return
  end

  local config = {
    version = "1.0",
    project_type = "custom",
  }

  if project_config.save_config(config, dir) and
      project_config.generate_ccls("custom", dir) then
    vim.schedule(function()
      vim.cmd("LspRestart")
    end)
  end
end

-- Edit .ccls file directly
M.edit_ccls = function()
  local config, config_dir = project_config.find_nearest_config()

  if not config_dir then
    vim.notify("No project config found. Run :ProjectSetup first.", vim.log.levels.WARN)
    return
  end

  local ccls_path = config_dir .. "/.ccls"

  if vim.fn.filereadable(ccls_path) == 0 then
    -- Generate it first
    if config and config.project_type then
      project_config.generate_ccls(config.project_type, config_dir)
    end
  end

  vim.cmd("edit " .. ccls_path)
end

-- Show current config
M.show_project_config = function()
  local config, config_dir = project_config.find_nearest_config()

  if not config then
    vim.notify("No project config found", vim.log.levels.WARN)
    return
  end

  local lines = {
    "Project Configuration:",
    "Location: " .. config_dir,
    "Type: " .. config.project_type,
  }

  local ccls_path = config_dir .. "/.ccls"
  if vim.fn.filereadable(ccls_path) == 1 then
    table.insert(lines, "Config file: .ccls")
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

return M
