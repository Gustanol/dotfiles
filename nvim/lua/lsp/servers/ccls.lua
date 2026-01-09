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
    --"/lib/modules/" .. kernel_release .. "/build",
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

-- Auto-detect project type
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

  return "custom"
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

-- Build compiler flags
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

  for _, path in ipairs(config.include_paths or {}) do
    table.insert(flags.extraArgs, "-I" .. path)
  end

  return flags
end

-- Track configured roots to avoid duplicates
local configured_roots = {}

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

  -- Generate unique server name based on root path
  local root_hash = vim.fn.sha256(config_dir):sub(1, 8)
  local server_name = "ccls_" .. root_hash

  -- Store server name in buffer for tracking
  vim.b[bufnr].ccls_server_name = server_name

  -- Check if server is already running for this root
  local existing_client = nil
  for _, client in ipairs(vim.lsp.get_clients({ name = server_name })) do
    if client.config.root_dir == config_dir then
      existing_client = client
      break
    end
  end

  if existing_client then
    -- Attach existing client to this buffer
    vim.lsp.buf_attach_client(bufnr, existing_client.id)
    return
  end

  -- Setup new instance if not already configured
  if not configured_roots[config_dir] then
    local compiler_flags = build_compiler_flags(config, config_dir)

    local lsp_config = {
      name = server_name,
      cmd = { "ccls" },
      root_dir = config_dir,

      capabilities = lsp.capabilities,

      on_attach = function(client, buf)
        lsp.on_attach(client, buf)

        if not vim.b[buf].ccls_notified then
          local msg = "CCLS: " .. config.project_type:gsub("_", " ")
          msg = msg .. "\nRoot: " .. vim.fn.fnamemodify(config_dir, ":~")
          vim.notify(msg, vim.log.levels.INFO)
          vim.b[buf].ccls_notified = true
        end
      end,

      on_exit = function()
        configured_roots[config_dir] = nil
        vim.notify("CCLS stopped: " .. vim.fn.fnamemodify(config_dir, ":~"), vim.log.levels.INFO)
      end,

      filetypes = { "c", "cpp", "h", "objc", "objcpp" },

      init_options = {
        cache = {
          directory = vim.fn.stdpath("cache") .. "/ccls/" .. root_hash,
          retainInMemory = 1,
        },
        compilationDatabaseDirectory = config_dir,
        index = {
          threads = 1,
          onChange = false,
          initialBlacklist = { ".*test.*", ".*build.*", ".*/\\..*" },
        },
        completion = {
          detailedLabel = true,
          enableSnippetInsertion = false,
          placeholder = false,
          include = {
            maxPathSize = 30,
            suffixWhitelist = { ".h", ".hpp", ".hh", ".hxx" },
          },
        },
        diagnostics = {
          onOpen = 0,
          onChange = 0,
        },
        client = {
          snippetSupport = false,
        },
        clang = compiler_flags,
      },
    }

    configured_roots[config_dir] = server_name

    -- Start the LSP client
    vim.lsp.start(lsp_config, {
      bufnr = bufnr,
    })
  end
end

-- Setup on C/C++ file open
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "objc", "objcpp" },
  callback = function(ev)
    setup_ccls_for_buffer(ev.buf)
  end,
})
