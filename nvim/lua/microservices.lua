local M = {}

function M.detect_microservice()
    local current_dir = vim.fn.expand("%:p:h")
    local markers = { "pom.xml", "build.gradle", "src/main/java" }

    for i = 0, 3 do
        local check_dir = current_dir
        for j = 1, i do
            check_dir = vim.fn.fnamemodify(check_dir, ":h")
        end

        for _, marker in ipairs(markers) do
            if
                vim.fn.filereadable(check_dir .. "/" .. marker) == 1
                or vim.fn.isdirectory(check_dir .. "/" .. marker) == 1
            then
                return check_dir
            end
        end
    end

    return nil
end

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
            local project_root = M.detect_microservice()
            if project_root then
                vim.b.jdtls_project_root = project_root
                print("Detected microservice project at: " .. project_root)
            end
        end,
    })
end

return M
