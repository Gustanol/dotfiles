-- ~/.config/nvim/lua/plugins/disable-java.lua

return {
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        config = function() end,
    },

    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}

            local filtered = {}
            for _, tool in ipairs(opts.ensure_installed) do
                if tool ~= "jdtls" and tool ~= "spring-boot-tools" and tool ~= "java-language-server" then
                    table.insert(filtered, tool)
                end
            end
            opts.ensure_installed = filtered
            opts.automatic_installation = false
            opts.auto_update = false

            return opts
        end,
    },

    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            opts.servers = opts.servers or {}
            opts.servers.jdtls = nil

            if opts.setup then
                opts.setup.jdtls = function() end
            end

            return opts
        end,
    },

    {
        "LazyVim/LazyVim",
        opts = function(_, opts)
            if opts.extras then
                local filtered_extras = {}
                for _, extra in ipairs(opts.extras) do
                    if not string.match(extra, "java") then
                        table.insert(filtered_extras, extra)
                    end
                end
                opts.extras = filtered_extras
            end
            return opts
        end,
    },
}
