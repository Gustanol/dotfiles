-- ~/.config/nvim/ftplugin/java.lua

local jdtls = require("jdtls")

local function get_project_root()
    local markers = { "pom.xml", "build.gradle", "build.gradle.kts" }
    local current_dir = vim.fn.expand("%:p:h")

    for _, marker in ipairs(markers) do
        local found = vim.fn.findfile(marker, current_dir .. ";")
        if found ~= "" then
            return vim.fn.fnamemodify(found, ":p:h")
        end
    end

    return vim.fn.getcwd()
end

local project_root = get_project_root()
local project_name = vim.fn.fnamemodify(project_root, ":t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

local jdtls_jar = vim.fn.glob("~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
if jdtls_jar == "" then
    print("❌ JDTLS not found! Execute :MasonInstall jdtls")
    return
end

local config = {
    cmd = {
        "/usr/lib/jvm/java-17-openjdk/bin/java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "-Xmx2g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        jdtls_jar,
        "-configuration",
        "~/.local/share/nvim/mason/packages/jdtls/config_linux",
        "-data",
        workspace_dir,
    },

    root_dir = project_root,

    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-17",
                        path = "/usr/lib/jvm/java-17-openjdk/",
                        default = true,
                    },
                },
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = true,
            },
            signatureHelp = {
                enabled = true,
            },
            completion = {
                favoriteStaticMembers = {
                    "org.junit.jupiter.api.Assertions.*",
                    "org.mockito.Mockito.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                },
            },
            contentProvider = {
                preferred = "fernflower",
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                useBlocks = true,
            },
        },
        signatureHelp = {
            enabled = true,
        },
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
    },

    init_options = {
        bundles = {},
    },
}

jdtls.start_or_attach(config)

print("🚀 JDTLS iniciado - Projeto: " .. project_name .. " | Root: " .. project_root)

local opts = { noremap = true, silent = true, buffer = true }
vim.keymap.set(
    "n",
    "<leader>jo",
    '<cmd>lua require("jdtls").organize_imports()<cr>',
    vim.tbl_extend("force", opts, { desc = "Organize Imports" })
)
vim.keymap.set(
    "n",
    "<leader>jv",
    '<cmd>lua require("jdtls").extract_variable()<cr>',
    vim.tbl_extend("force", opts, { desc = "Extract Variable" })
)
vim.keymap.set(
    "v",
    "<leader>jm",
    '<cmd>lua require("jdtls").extract_method(true)<cr>',
    vim.tbl_extend("force", opts, { desc = "Extract Method" })
)
