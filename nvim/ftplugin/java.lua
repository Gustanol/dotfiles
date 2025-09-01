local jdtls = require("jdtls")
local jdtls_setup = require("jdtls.setup")

local function find_project_root()
    local markers = {
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
        "gradlew",
        "mvnw",
        "settings.gradle",
    }

    local current_dir = vim.fn.expand("%:p:h")
    local root = jdtls_setup.find_root(markers)

    if root then
        return root
    end

    return current_dir
end

vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
    if result.message:match("non%-file project") then
        return
    end
    vim.lsp.handlers["window/showMessage"](_, result, ctx)
end

local root_dir = find_project_root()

local workspace_folder = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. workspace_folder

local config = {
    cmd = {
        "jdtls",
        "-javaagent:" .. vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/lombok.jar"),
        "-Xms256m",
        "-Xmx768m",
        "-XX:+UseG1GC",
        "-XX:GCTimeRatio=19",
        "-XX:MaxGCPauseMillis=100",
        "-Djdt.indexEnabled=true",
        "-Djdt.indexTimeout=30000",
        "-data",
        workspace_dir,
    },

    root_dir = root_dir,

    settings = {
        java = {
            eclipse = {
                downloadSources = false,
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name}=${member.value}, ${otherMembers}}",
                },
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-21",
                        path = "/usr/lib/jvm/java-21-openjdk/",
                        default = true,
                    },
                },
            },
            compile = {
                nullAnalysis = {
                    mode = "automatic",
                },
            },
            signatureHelp = { enabled = true },
            completion = {
                maxResults = 20,
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                },
            },
            maven = {
                downloadSources = false,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            import = {
                gradle = {
                    enabled = true,
                },
                maven = {
                    enabled = true,
                },
                exclusions = {
                    "**/node_modules/**",
                    "**/.metadata/**",
                    "**/archetype-resources/**",
                    "**/META-INF/maven/**",
                },
            },
        },
    },

    init_options = {
        bundles = {},
    },
}

jdtls.start_or_attach(config)
