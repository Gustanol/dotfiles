-- ~/.config/nvim/lua/spring-boot-commands.lua

local M = {}

function M.find_spring_boot_services()
    local services = {}
    local handle = io.popen(
        'find . -name "application.properties" -o -name "application.yml" -o -name "application.yaml" | head -10'
    )

    if handle then
        for line in handle:lines() do
            local dir = vim.fn.fnamemodify(line, ":h:h:h")
            if dir ~= "." and vim.fn.isdirectory(dir .. "/src/main/java") == 1 then
                table.insert(services, dir)
            end
        end
        handle:close()
    end

    if #services == 0 then
        handle = io.popen('find . -name "pom.xml" -exec grep -l "spring-boot" {} \\; | head -10')
        if handle then
            for line in handle:lines() do
                local dir = vim.fn.fnamemodify(line, ":h")
                if dir ~= "." then
                    table.insert(services, dir)
                end
            end
            handle:close()
        end
    end

    return services
end

function M.switch_spring_service()
    local services = M.find_spring_boot_services()

    if #services == 0 then
        print("No Spring microservice found!")
        return
    end

    vim.ui.select(services, {
        prompt = "Select the Spring microservice:",
        format_item = function(item)
            local service_name = vim.fn.fnamemodify(item, ":t")
            local pom_file = item .. "/pom.xml"
            if vim.fn.filereadable(pom_file) == 1 then
                local pom_content = vim.fn.readfile(pom_file)
                for _, line in ipairs(pom_content) do
                    local artifact_id = string.match(line, "<artifactId>(.-)</artifactId>")
                    if artifact_id and artifact_id ~= "maven-archetype-quickstart" then
                        return artifact_id .. " (" .. service_name .. ")"
                    end
                end
            end
            return service_name
        end,
    }, function(choice)
        if choice then
            vim.cmd("cd " .. choice)
            vim.defer_fn(function()
                vim.cmd("JavaRestartServers")
                print("🚀 Trocado para: " .. vim.fn.fnamemodify(choice, ":t"))
            end, 100)
        end
    end)
end

function M.run_spring_boot_app()
    local current_dir = vim.fn.getcwd()

    if vim.fn.filereadable(current_dir .. "/pom.xml") == 1 then
        vim.cmd("terminal mvn spring-boot:run")
    elseif vim.fn.filereadable(current_dir .. "/build.gradle") == 1 then
        vim.cmd("terminal ./gradlew bootRun")
    else
        print("❌ Invalid Spring project!")
    end
end

-- Função para executar testes
function M.run_spring_tests()
    local current_dir = vim.fn.getcwd()

    if vim.fn.filereadable(current_dir .. "/pom.xml") == 1 then
        vim.cmd("terminal mvn test")
    elseif vim.fn.filereadable(current_dir .. "/build.gradle") == 1 then
        vim.cmd("terminal ./gradlew test")
    else
        print("❌ Not supported project!")
    end
end

function M.create_spring_structure()
    local templates = {
        controller = "src/main/java/com/example/controller/",
        service = "src/main/java/com/example/service/",
        repository = "src/main/java/com/example/repository/",
        model = "src/main/java/com/example/model/",
        dto = "src/main/java/com/example/dto/",
        config = "src/main/java/com/example/config/",
    }

    vim.ui.select(vim.tbl_keys(templates), {
        prompt = "Create structure:",
    }, function(choice)
        if choice then
            local path = templates[choice]
            vim.fn.mkdir(path, "p")
            print("📁 Created: " .. path)
        end
    end)
end

function M.open_spring_file()
    local files = {
        ["Application Main"] = "src/main/java/**/Application.java",
        ["application.properties"] = "src/main/resources/application.properties",
        ["application.yml"] = "src/main/resources/application.yml",
        ["pom.xml"] = "pom.xml",
        ["build.gradle"] = "build.gradle",
    }

    vim.ui.select(vim.tbl_keys(files), {
        prompt = "Open Spring file:",
    }, function(choice)
        if choice then
            local pattern = files[choice]
            local found_files = vim.fn.glob(pattern, false, true)

            if #found_files > 0 then
                vim.cmd("edit " .. found_files[1])
            else
                print("❌ Not found file: " .. pattern)
            end
        end
    end)
end

function M.show_project_info()
    local current_dir = vim.fn.getcwd()
    local project_name = vim.fn.fnamemodify(current_dir, ":t")

    print("📋 Spring project info:")
    print("  Name: " .. project_name)
    print("  Directory: " .. current_dir)

    if vim.fn.filereadable("pom.xml") == 1 then
        print("  Build: Maven")
        local pom_content = table.concat(vim.fn.readfile("pom.xml"), "\n")
        local spring_version = string.match(pom_content, "<spring%-boot%.version>(.-)</spring%-boot%.version>")
        if spring_version then
            print("  Spring: " .. spring_version)
        end
    elseif vim.fn.filereadable("build.gradle") == 1 then
        print("  Build: Gradle")
    end

    local app_props = "src/main/resources/application.properties"
    if vim.fn.filereadable(app_props) == 1 then
        local props_content = table.concat(vim.fn.readfile(app_props), "\n")
        local active_profile = string.match(props_content, "spring%.profiles%.active=(.+)")
        if active_profile then
            print("  Profile Ativo: " .. active_profile)
        end
    end
end

local function setup_commands()
    vim.api.nvim_create_user_command("SpringSwitch", M.switch_spring_service, { desc = "Switch Spring Boot Service" })
    vim.api.nvim_create_user_command("SpringRun", M.run_spring_boot_app, { desc = "Run Spring Boot Application" })
    vim.api.nvim_create_user_command("SpringTest", M.run_spring_tests, { desc = "Run Spring Boot Tests" })
    vim.api.nvim_create_user_command(
        "SpringCreate",
        M.create_spring_structure,
        { desc = "Create Spring Boot Structure" }
    )
    vim.api.nvim_create_user_command("SpringOpen", M.open_spring_file, { desc = "Open Spring Boot File" })
    vim.api.nvim_create_user_command("SpringInfo", M.show_project_info, { desc = "Show Spring Boot Project Info" })
end

local function setup_keymaps()
    local opts = { noremap = true, silent = true }

    vim.keymap.set(
        "n",
        "<leader>ss",
        M.switch_spring_service,
        vim.tbl_extend("force", opts, { desc = "Switch Spring Service" })
    )
    vim.keymap.set("n", "<leader>sr", M.run_spring_boot_app, vim.tbl_extend("force", opts, { desc = "Run Spring App" }))
    vim.keymap.set("n", "<leader>st", M.run_spring_tests, vim.tbl_extend("force", opts, { desc = "Run Spring Tests" }))
    vim.keymap.set(
        "n",
        "<leader>sc",
        M.create_spring_structure,
        vim.tbl_extend("force", opts, { desc = "Create Spring Structure" })
    )
    vim.keymap.set("n", "<leader>so", M.open_spring_file, vim.tbl_extend("force", opts, { desc = "Open Spring File" }))
    vim.keymap.set(
        "n",
        "<leader>si",
        M.show_project_info,
        vim.tbl_extend("force", opts, { desc = "Spring Project Info" })
    )

    vim.keymap.set(
        "n",
        "<leader>jr",
        "<cmd>JavaRestartServers<cr>",
        vim.tbl_extend("force", opts, { desc = "Restart Java Servers" })
    )
    vim.keymap.set(
        "n",
        "<leader>jt",
        "<cmd>JavaRunnerRunMain<cr>",
        vim.tbl_extend("force", opts, { desc = "Run Java Main" })
    )
    vim.keymap.set(
        "n",
        "<leader>jd",
        "<cmd>JavaRunnerToggleLogs<cr>",
        vim.tbl_extend("force", opts, { desc = "Toggle Java Logs" })
    )
end

function M.setup()
    setup_commands()
    setup_keymaps()
    print("🍃 Spring Boot commands loaded!")
end

return M
