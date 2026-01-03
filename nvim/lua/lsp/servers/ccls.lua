local lsp = require("lsp.config")
local project_config = require("core.project-config")

-- Only load for C/C++ files
local current_ft = vim.bo.filetype
if current_ft ~= "" and not vim.tbl_contains({ "c", "cpp", "h", "objc", "objcpp" }, current_ft) then
  return
end

-- Get kernel headers path
local function get_kernel_headers_path()
  local kernel_release = vim.fn.system("uname -r"):gsub("\n", "")
  local paths = {
    "~/qemu-lab/linux-6.17.8/",
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

-- Auto-detect project type (fallback if no config file)
local function auto_detect_project_type(dir)
  if vim.fn.filereadable(dir .. "/Kconfig") == 1 and
      vim.fn.isdirectory(dir .. "/arch") == 1 and
      vim.fn.filereadable(dir .. "/MAINTAINERS") == 1 then
    return "linux_kernel"
  end

  if (vim.fn.glob(dir .. "/*.ko") ~= "" or
        vim.fn.filereadable(dir .. "/Module.symvers") == 1) and
      vim.fn.filereadable(dir .. "/Kconfig") == 0 then
    return "linux_module"
  end

  return "userspace"
end

-- Get GCC include paths
local function get_gcc_includes()
  local handle = io.popen("gcc -E -Wp,-v -xc /dev/null 2>&1 | grep '^ ' | tr -d ' '")
  local result = {}
  if handle then
    for line in handle:lines() do
      if line ~= "" then
        table.insert(result, line)
      end
    end
    handle:close()
  end
  return result
end

-- Build compiler flags based on project type
local function build_compiler_flags(config, config_dir)
  local flags = {
    excludeArgs = {},
    extraArgs = {},
  }

  if config.project_type == "linux_kernel" then
    flags.excludeArgs = {
      "-mpreferred-stack-boundary=*",
      "-mindirect-branch=*",
      "-mindirect-branch-register",
      "-fno-allow-store-data-races",
      "-fconserve-stack",
      "-mrecord-mcount",
    }
    flags.extraArgs = {
      "-nostdinc",
      "-D__KERNEL__",
      "-DCONFIG_X86_64",
      "-I" .. config_dir .. "/arch/x86/include",
      "-I" .. config_dir .. "/arch/x86/include/generated",
      "-I" .. config_dir .. "/include",
      "-I" .. config_dir .. "/arch/x86/include/uapi",
      "-I" .. config_dir .. "/include/uapi",
    }
  elseif config.project_type == "linux_module" then
    local kernel_headers = get_kernel_headers_path()
    if kernel_headers then
      flags.excludeArgs = {
        "-mpreferred-stack-boundary=*",
        "-mindirect-branch=*",
      }
      flags.extraArgs = {
        "-nostdinc",
        "-D__KERNEL__",
        "-DMODULE",
        "-DCONFIG_X86_64",
        "-I" .. kernel_headers .. "/arch/x86/include",
        "-I" .. kernel_headers .. "/arch/x86/include/generated",
        "-I" .. kernel_headers .. "/include",
        "-I" .. kernel_headers .. "/arch/x86/include/uapi",
        "-I" .. kernel_headers .. "/include/uapi",
      }
    end
  elseif config.project_type == "custom" then
    flags.extraArgs = config.custom_flags or {}
  else -- userspace
    flags.extraArgs = vim.tbl_map(function(path)
      return "-I" .. path
    end, get_gcc_includes())
  end

  -- Add custom include paths
  for _, path in ipairs(config.include_paths or {}) do
    table.insert(flags.extraArgs, "-I" .. path)
  end

  return flags
end

-- Track active CCLS instances by root
local active_instances = {}

-- Setup CCLS on buffer enter
local function setup_ccls_for_buffer(bufnr)
  local config, config_dir = project_config.get_buffer_config(bufnr)

  if not config then
    local buffer_path = vim.api.nvim_buf_get_name(bufnr)
    local buffer_dir = vim.fn.fnamemodify(buffer_path, ":p:h")
    local detected_type = auto_detect_project_type(buffer_dir)

    config = {
      project_type = detected_type,
      custom_flags = {},
      include_paths = {},
    }
    config_dir = buffer_dir

    vim.b[bufnr].project_config = config
    vim.b[bufnr].project_config_dir = config_dir
  end

  -- Check if we already have an instance for this root
  if active_instances[config_dir] then
    -- Just attach to existing instance
    return
  end

  local compiler_flags = build_compiler_flags(config, config_dir)

  -- Mark this root as having an active instance
  active_instances[config_dir] = true

  vim.lsp.config("ccls", {
    name = "ccls_" .. vim.fn.fnamemodify(config_dir, ":t"), -- Unique name per root
    capabilities = lsp.capabilities,
    on_attach = function(client, buf)
      lsp.on_attach(client, buf)

      if not vim.b[buf].ccls_notified then
        local msg = "CCLS: " .. config.project_type:gsub("_", " ")
        if config_dir then
          msg = msg .. "\nRoot: " .. vim.fn.fnamemodify(config_dir, ":~")
        end
        vim.notify(msg, vim.log.levels.INFO)
        vim.b[buf].ccls_notified = true
      end
    end,

    on_exit = function()
      -- Clean up when instance exits
      active_instances[config_dir] = nil
    end,

    cmd = { "ccls" },
    root_dir = config_dir,

    init_options = {
      cache = {
        directory = vim.fn.stdpath("cache") .. "/ccls/" .. vim.fn.fnamemodify(config_dir, ":t"),
        retainInMemory = 1, -- Keep less in memory
      },
      compilationDatabaseDirectory = config_dir,
      index = {
        threads = 1,      -- Reduce to 1 thread for lower CPU usage
        onChange = false, -- Don't reindex on every change
        initialBlacklist = { ".*test.*", ".*build.*", ".*/\\..*" },
      },
      completion = {
        detailedLabel = true,
        enableSnippetInsertion = false, -- Reduce CPU for completion
        include = {
          maxPathSize = 30,
          suffixWhitelist = { ".h", ".hpp", ".hh", ".hxx" },
          whitelist = {},
          blacklist = {},
        },
      },
      client = {
        snippetSupport = false, -- Disable snippets to reduce CPU
      },
      clang = compiler_flags,
    },

    filetypes = { "c", "h", "cpp", "objc", "objcpp" },
  })
end

-- Setup on C/C++ file open
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "objc", "objcpp" },
  callback = function(ev)
    setup_ccls_for_buffer(ev.buf)
    vim.lsp.enable("ccls")
  end,
})
