return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")

    -- Create custom header source inline
    local header_source = {}

    -- Get project include directories
    local function get_include_dirs()
      local project_config = require("core.project-config")
      local config, config_dir = project_config.get_buffer_config()

      if not config then
        return {}
      end

      local includes = {}

      if config.project_type == "linux_kernel" then
        table.insert(includes, config_dir .. "/include")
        table.insert(includes, config_dir .. "/arch/x86/include")
      elseif config.project_type == "linux_module" then
        local kernel_headers = "~/qemu-lab/linux-6.17.8/"
        if vim.fn.isdirectory(kernel_headers) == 1 then
          table.insert(includes, kernel_headers .. "/include")
          table.insert(includes, kernel_headers .. "/arch/x86/include")
        end
      elseif config.project_type == "custom" or config.project_type == "userspace" then
        if vim.fn.isdirectory(config_dir .. "/include") == 1 then
          table.insert(includes, config_dir .. "/include")
        end
      end

      return includes
    end

    -- Find header files
    local function find_headers(pattern)
      local headers = {}
      local include_dirs = get_include_dirs()

      for _, dir in ipairs(include_dirs) do
        if vim.fn.isdirectory(dir) == 1 then
          local cmd = string.format("find %s -name '*.h' 2>/dev/null | head -n 50", vim.fn.shellescape(dir))
          local handle = io.popen(cmd)

          if handle then
            for line in handle:lines() do
              local rel_path = line:gsub("^" .. vim.pesc(dir) .. "/", "")

              if pattern == "" or rel_path:find(pattern, 1, true) then
                table.insert(headers, {
                  label = rel_path,
                  kind = cmp.lsp.CompletionItemKind.File,
                  insertText = rel_path,
                  documentation = "Header from: " .. vim.fn.fnamemodify(dir, ":~"),
                })
              end

              if #headers >= 30 then
                break
              end
            end
            handle:close()
          end
        end
      end

      return headers
    end

    header_source.new = function()
      return setmetatable({}, { __index = header_source })
    end

    header_source.get_trigger_characters = function()
      return { "<", '"', "/" }
    end

    header_source.is_available = function()
      return vim.tbl_contains({ "c", "cpp", "h", "objc", "objcpp" }, vim.bo.filetype)
    end

    header_source.complete = function(self, params, callback)
      local line = params.context.cursor_before_line

      -- Check if in #include directive
      local include_match = line:match('#include%s+[<"]([^>"]*)')

      if include_match then
        local headers = find_headers(include_match)
        callback({ items = headers, isIncomplete = false })
      else
        callback({ items = {}, isIncomplete = false })
      end
    end

    -- Register the source
    cmp.register_source("headers", header_source.new())

    -- Add to sources if not already present
    opts.sources = opts.sources or cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "buffer" },
    })

    -- Insert header source after nvim_lsp
    table.insert(opts.sources, 2, {
      name = "headers",
      priority = 900,
      max_item_count = 30,
    })

    return opts
  end,
}
