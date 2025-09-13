return {
  {
    dir = vim.fn.stdpath("config"),
    name = "home-dashboard",
    dev = true,
    priority = 1000,
    lazy = false,
    config = function()
      local M = {}

      function M.center_text(text, width)
        local padding = math.floor((width - vim.fn.strdisplaywidth(text)) / 2)
        return string.rep(" ", padding) .. text
      end

      function M.create_home_buffer()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, "dashboard://home")
        
        vim.bo[buf].buftype = 'nofile'
        vim.bo[buf].swapfile = false
        vim.bo[buf].buflisted = false
        vim.bo[buf].modifiable = false
        vim.bo[buf].readonly = true
        vim.bo[buf].bufhidden = 'wipe'

        local win_height = vim.api.nvim_win_get_height(0)
        local win_width = vim.api.nvim_win_get_width(0)

        local dashboard_lines = {
            [[/$$   /$$                     /$$    /$$ /$$]],
            [[| $$$ | $$                    | $$   | $$|__/]],
            [[| $$$$| $$  /$$$$$$   /$$$$$$ | $$   | $$ /$$ /$$$$$$/$$$$]],
            [[| $$ $$ $$ /$$__  $$ /$$__  $$|  $$ / $$/| $$| $$_  $$_  $$]],
            [[| $$  $$$$| $$$$$$$$| $$  \ $$ \  $$ $$/ | $$| $$ \ $$ \ $$]],
            [[| $$\  $$$| $$_____/| $$  | $$  \  $$$/  | $$| $$ | $$ | $$]],
            [[| $$ \  $$|  $$$$$$$|  $$$$$$/   \  $/   | $$| $$ | $$ | $$]],
            [[|__/  \__/ \_______/ \______/     \_/    |__/|__/ |__/ |__/]],
            [[]],
            [[╔══════════════════════════════════════╗]],
            [[║                                      ║]],
            [[║  🚀  Commands:                       ║]],
            [[║                                      ║]],
            [[║  f - Find files                      ║]],
            [[║  g - Grep files                      ║]],
            [[║  r - Recent files                    ║]],
            [[║  n - New file                        ║]],
            [[║  q - Quit                            ║]],
            [[║                                      ║]],
            [[║  u - Update plugins                  ║]],
            [[║  c - Configuration                   ║]],
                [[║  p - Projects                        ║]],
            [[║                                      ║]],
            [[╚══════════════════════════════════════╝]],
}

        local dashboard_height = #dashboard_lines
        local vertical_padding = math.max(0, math.floor((win_height - dashboard_height) / 2))

        local lines = {}
        
        for i = 1, vertical_padding do
          table.insert(lines, "")
        end
        
        for _, line in ipairs(dashboard_lines) do
          table.insert(lines, M.center_text(line, win_width))
        end
        
        local remaining_lines = win_height - #lines
        for i = 1, remaining_lines do
          table.insert(lines, "")
        end

        vim.bo[buf].readonly = false
        vim.bo[buf].modifiable = true
        
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        
        vim.bo[buf].modifiable = false
        vim.bo[buf].readonly = true

        return buf
      end

      function M.setup_keymaps(buf)
        local keymaps = {
          { 'f', ':Telescope find_files<CR>', 'Find files' },
          { 'g', ':Telescope live_grep<CR>', 'Grep files' },
          { 'r', ':Telescope oldfiles<CR>', 'Recent files' },
          { 'n', ':enew<CR>', 'New file' },
          { 'q', ':qa<CR>', 'Quit' },
          { 'u', ':Lazy update<CR>', 'Update plugins' },
          { 'c', ':e ~/.config/nvim/init.lua<CR>', 'Configuration' },
          { 'p', ':Telescope projects<CR>', 'Projects' },
          { '<Esc>', ':enew<CR>', 'Close dashboard' },
        }

        for _, keymap in ipairs(keymaps) do
          vim.keymap.set('n', keymap[1], keymap[2], {
            silent = true,
            buffer = buf,
            desc = keymap[3],
            nowait = true,
          })
        end

        vim.keymap.set('n', 'i', '<Nop>', { buffer = buf })
        vim.keymap.set('n', 'I', '<Nop>', { buffer = buf })
        vim.keymap.set('n', 'a', '<Nop>', { buffer = buf })
        vim.keymap.set('n', 'A', '<Nop>', { buffer = buf })
        vim.keymap.set('n', 'o', '<Nop>', { buffer = buf })
        vim.keymap.set('n', 'O', '<Nop>', { buffer = buf })
      end

      function M.recenter_dashboard()
        local buf = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(buf)
        
        if buf_name == "dashboard://home" then
          local new_buf = M.create_home_buffer()
          vim.api.nvim_win_set_buf(0, new_buf)
          M.setup_keymaps(new_buf)
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end

      vim.api.nvim_create_user_command('Home', function()
        local buf = M.create_home_buffer()
        vim.api.nvim_win_set_buf(0, buf)
        M.setup_keymaps(buf)
      end, { desc = 'Open Home Dashboard' })

      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("HomeDashboardResize", { clear = true }),
        callback = M.recenter_dashboard,
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("HomeDashboard", { clear = true }),
        callback = function()
          if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 then
            vim.schedule(function()
              vim.cmd("Home")
            end)
          end
        end,
      })
    end,
    keys = {
      { "<leader>h", "<cmd>Home<cr>", desc = "Open Home Dashboard" },
    },
  }
}
