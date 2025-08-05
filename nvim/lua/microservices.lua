-- ~/.config/nvim/lua/microservices.lua
local M = {}

function M.find_microservices()
    local services = {}
    local handle = io.popen('find . -name "pom.xml" -o -name "build.gradle" | head -20')

    if handle then
        for line in handle:lines() do
            local dir = vim.fn.fnamemodify(line, ":h")
            if dir ~= "." then
                table.insert(services, dir)
            end
        end
        handle:close()
    end

    return services
end

function M.switch_service()
    local services = M.find_microservices()

    vim.ui.select(services, {
        prompt = "Selecione o microsserviço:",
        format_item = function(item)
            return vim.fn.fnamemodify(item, ":t")
        end,
    }, function(choice)
        if choice then
            vim.cmd("cd " .. choice)
            vim.cmd("LspRestart")
            print("Trocado para: " .. choice)
        end
    end)
end

return M
