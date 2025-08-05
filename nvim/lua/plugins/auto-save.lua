return {
    "Pocco81/auto-save.nvim",

    lazy = false,
    config = function()
        require("auto-save").setup({
            enabled = true,
            execution_message = {
                message = function()
                    return "AutoSave ✅ " .. vim.fn.strftime("%H:%M:%S")
                end,
                dim = 0.15,
                cleaning_interval = 1000,
            },
            trigger_events = {
                immediate_save = { "BufLeave", "FocusLost" },
                defer_save = { "InsertLeave", "TextChanged" },
                cancel_deferred_save = { "InsertEnter" },
            },
            --  condition = function(buf)
            --      local bt = vim.fn.getbufvar(buf, "&buftype")
            --      local ft = vim.fn.getbufvar(buf, "&filetype")
            --      return bt == "" and vim.bo[buf].modifiable and ft ~= "gitcommit"
            --  end,
            write_all_buffers = false,
            debounce_delay = 250,
            debug = false,
        })
    end,
}
