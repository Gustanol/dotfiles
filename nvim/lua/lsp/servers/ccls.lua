local lsp = require("lsp.config")
local project_config = require("core.project-config")

-- Auto-detect project type (simplified)
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

-- Track configured roots
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
    }
    config_dir = buffer_dir

    vim.b[bufnr].project_config = config
    vim.b[bufnr].project_config_dir = config_dir
  end

  -- Generate unique server name
  local root_hash = vim.fn.sha256(config_dir):sub(1, 8)
  local server_name = "ccls_" .. root_hash

  vim.b[bufnr].ccls_server_name = server_name

  -- Check if server already running
  local existing_client = nil
  for _, client in ipairs(vim.lsp.get_clients({ name = server_name })) do
    if client.config.root_dir == config_dir then
      existing_client = client
      break
    end
  end

  if existing_client then
    vim.lsp.buf_attach_client(bufnr, existing_client.id)
    return
  end

  -- Setup new instance
  if not configured_roots[config_dir] then
    -- CCLS will read .ccls file automatically - minimal config needed
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

          local ccls_file = config_dir .. "/.ccls"
          if vim.fn.filereadable(ccls_file) == 1 then
            msg = msg .. "\nUsing: .ccls"
          end

          vim.notify(msg, vim.log.levels.INFO)
          vim.b[buf].ccls_notified = true
        end
      end,

      on_exit = function()
        configured_roots[config_dir] = nil
        vim.notify("CCLS stopped: " .. vim.fn.fnamemodify(config_dir, ":~"), vim.log.levels.INFO)
      end,

      filetypes = { "c", "cpp", "h", "objc", "objcpp" },

      -- Minimal init_options - let .ccls handle flags
      init_options = {
        cache = {
          directory = vim.fn.stdpath("cache") .. "/ccls/" .. root_hash,
        },
        index = {
          threads = 1,
          onChange = true,
        },
      },
    }

    configured_roots[config_dir] = server_name

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
