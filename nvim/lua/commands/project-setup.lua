local M = {}
local project_config = require("core.project-config")

-- Project type options
local project_types = {
  { name = "Userspace Project",           value = "userspace" },
  { name = "Linux Kernel Source Tree",    value = "linux_kernel" },
  { name = "Linux Kernel Module",         value = "linux_module" },
  { name = "Custom (use Makefile flags)", value = "custom" },
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

-- Select directory for config file
M.select_directory = function(callback)
  local current_dir = vim.fn.getcwd()

  vim.ui.input({
    prompt = "Where to save .nvim-project.json? ",
    default = current_dir,
    completion = "dir",
  }, function(input)
    if input then
      -- Expand to absolute path
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
        custom_flags = {},
        include_paths = {},
      }

      -- For custom projects, extract Makefile flags
      if project_type == "custom" then
        local makefile_flags = project_config.extract_makefile_flags(dir)
        if #makefile_flags > 0 then
          config.custom_flags = makefile_flags
          vim.notify(
            "Extracted " .. #makefile_flags .. " flags from Makefile",
            vim.log.levels.INFO
          )
        else
          vim.notify(
            "No flags found in Makefile. You can edit .nvim-project.json manually.",
            vim.log.levels.WARN
          )
        end
      end

      -- Save configuration
      if project_config.save_config(config, dir) then
        -- Restart LSP to apply new configuration
        vim.schedule(function()
          vim.cmd("LspRestart")
        end)
      end
    end)
  end)
end

-- Show current project configuration
M.show_project_config = function()
  local config, config_dir = project_config.find_nearest_config()

  if not config then
    vim.notify("No .nvim-project.json found", vim.log.levels.WARN)
    return
  end

  local lines = {
    "Project Configuration:",
    "Location: " .. config_dir .. "/.nvim-project.json",
    "Type: " .. config.project_type,
  }

  if #config.custom_flags > 0 then
    table.insert(lines, "Custom flags:")
    for _, flag in ipairs(config.custom_flags) do
      table.insert(lines, "  " .. flag)
    end
  end

  if #config.include_paths > 0 then
    table.insert(lines, "Include paths:")
    for _, path in ipairs(config.include_paths) do
      table.insert(lines, "  " .. path)
    end
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

-- Edit project configuration
M.edit_project_config = function()
  local config, config_dir = project_config.find_nearest_config()

  if not config then
    vim.notify("No .nvim-project.json found. Creating one...", vim.log.levels.INFO)
    M.create_project_config()
    return
  end

  vim.cmd("edit " .. config_dir .. "/.nvim-project.json")
end

return M
