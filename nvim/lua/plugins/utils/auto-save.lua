return {
    {
        "okuuva/auto-save.nvim",
        cmd = "ASToggle", -- lazy load on command
        event = { "InsertLeave", "TextChanged" },
        keys = {
            { "<leader>as", "<cmd>ASToggle<CR>", desc = "Toggle Auto-Save" },
        },
        opts = {
            enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
            trigger_events = { -- vim events that trigger auto-save. See :h events
                immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" }, -- vim events that trigger an immediate save
                defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
                cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
            },
            -- function that takes the buffer handle and determines whether to save the current buffer or not
            -- return true: if buffer is ok to be saved
            -- return false: if it's not ok to be saved
            -- if set to `nil` then no specific condition is applied
            condition = nil,
            write_all_buffers = false, -- write all buffers when the current one meets `condition`
            noautocmd = false, -- do not execute autocmds when saving
            lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
            debounce_delay = 1000, -- delay after which a pending save is executed
            -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
            debug = false,
        },
    },

    {
        "tmillr/sos.nvim",
        event = { "InsertLeave", "TextChanged" },
        opts = {
            enabled = true,
            timeout = 20000,
            autowrite = true,
            save_on_cmd = "some",
            save_on_bufleave = true,
            save_on_focuslost = true,
        },
        config = function(_, opts)
            require("sos").setup(opts)
        end,
    },
}
