return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local asm_group = vim.api.nvim_create_augroup("AssemblyConfig", { clear = true })

    local function asm_symbols()
      local ft = vim.bo.filetype
      if ft ~= "gas" then
        vim.notify("AsmSymbols can only be used with GAS (in here)", vim.log.levels.WARN)
        return
      end

      local symbols = {}
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      for i, line in ipairs(lines) do
        local label = line:match("^([%w_]+):")
        if label then
          table.insert(symbols, { lnum = i, text = label, type = "label" })
        else
          local func = line:match("%.global%s+([%w_]+)")
          if func then
            table.insert(symbols, { lnum = i, text = func, type = "function" })
          else
            local var = line:match("^([%w_]+):")
            if var then
              local last = symbols[#symbols]
              if not last or last.text ~= var then
                table.insert(symbols, { lnum = i, text = var, type = "variable" })
              end
            end
          end
        end
      end

      pickers
          .new({}, {
            prompt_title = "Assembly Symbols",
            finder = finders.new_table({
              results = symbols,
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = string.format("[%s] %s", entry.type, entry.text),
                  ordinal = entry.text,
                  lnum = entry.lnum,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
              end)
              return true
            end,
          })
          :find()
    end

    vim.api.nvim_create_user_command("AsmSymbols", asm_symbols, {})
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { "*.s", "*.S" },
      callback = function()
        vim.bo.filetype = "gas"
      end,
      group = asm_group,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "asm", "gas" },
      callback = function()
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
        vim.bo.expandtab = true
        vim.bo.commentstring = "# %s"
        vim.wo.colorcolumn = "80"
        vim.cmd([[match ExtraWhitespace /\s\+$/]])

        vim.keymap.set(
          "n",
          "<leader>ay",
          "<cmd>AsmSymbols<cr>",
          { buffer = true, silent = true, desc = "Assembly: Symbols" }
        )
      end,
      group = asm_group,
    })

    vim.keymap.set(
      "n",
      "<leader>ah",
      "<cmd>AsmCheatsheet<cr>",
      { noremap = true, silent = true, desc = "Assembly: Cheatsheet" }
    )
  end,
}
