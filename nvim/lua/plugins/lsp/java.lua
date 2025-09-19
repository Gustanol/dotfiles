return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      local jdtls_cache = {}

      local function setup_jdtls()
        local jdtls = require("jdtls")

        local function find_monorepo_root()
          local current_dir = vim.fn.getcwd()
          local markers = {
            "settings.gradle",
            "settings.gradle.kts",
            ".git",
            "gradlew",
            "build.gradle",
          }

          local root = current_dir
          while root ~= "/" do
            for _, marker in ipairs(markers) do
              if vim.fn.filereadable(root .. "/" .. marker) == 1 then
                if marker:match("settings%.gradle") then
                  return root, true
                elseif marker == ".git" or marker == "gradlew" then
                  if
                    vim.fn.filereadable(root .. "/settings.gradle") == 1
                    or vim.fn.filereadable(root .. "/settings.gradle.kts") == 1
                  then
                    return root, true
                  end
                end
              end
            end
            root = vim.fn.fnamemodify(root, ":h")
          end

          return current_dir, false
        end

        local workspace_root, is_monorepo = find_monorepo_root()
        local workspace_name = vim.fn.fnamemodify(workspace_root, ":t")

        if not is_monorepo then
          workspace_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end

        if not jdtls_cache.paths then
          local mason_path = vim.fn.stdpath("data") .. "/mason"
          jdtls_cache.paths = {
            mason = mason_path,
            jdtls = mason_path .. "/packages/jdtls",
            workspace_base = vim.fn.stdpath("data") .. "/jdtls-workspaces",
          }
        end

        local workspace_dir
        if is_monorepo then
          workspace_dir = jdtls_cache.paths.workspace_base .. "/monorepo-" .. workspace_name
          print("🏗️  Using shared workspace: " .. workspace_name)
        else
          workspace_dir = jdtls_cache.paths.workspace_base .. "/" .. workspace_name
          print("📁 Using single workspace: " .. workspace_name)
        end

        if jdtls_cache.active_workspace == workspace_dir then
          print("♻️  JDTLS already active in this workspace")
          return
        end

        vim.fn.system(string.format("mkdir -p '%s'/{.metadata,.plugins}", workspace_dir))

        if not jdtls_cache.os_config then
          jdtls_cache.os_config = "config_linux"
        end

        if not jdtls_cache.launcher_jar then
          local launcher_jar =
            vim.fn.glob(jdtls_cache.paths.jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar")
          if launcher_jar == "" then
            vim.notify("JDTLS launcher jar not found!", vim.log.levels.ERROR)
            return
          end
          jdtls_cache.launcher_jar = launcher_jar
        end

        local project_cache_key = "project_" .. workspace_name
        if not jdtls_cache[project_cache_key] then
          local project_info = {
            is_spring_boot = false,
            is_gradle = false,
            is_maven = false,
            is_multimodule = is_monorepo,
            java_version = "21",
            subprojects = {},
          }

          local root_files_to_check = {
            { file = workspace_root .. "/settings.gradle", type = "gradle_multi" },
            { file = workspace_root .. "/settings.gradle.kts", type = "gradle_multi" },
            { file = workspace_root .. "/build.gradle", type = "gradle" },
            { file = workspace_root .. "/build.gradle.kts", type = "gradle" },
            { file = workspace_root .. "/pom.xml", type = "maven" },
          }

          for _, check in ipairs(root_files_to_check) do
            if vim.fn.filereadable(check.file) == 1 then
              local content = table.concat(vim.fn.readfile(check.file), "\n")
              project_info.main_build_file = check.file

              if check.type:match("gradle") then
                project_info.is_gradle = true
                if check.type == "gradle_multi" then
                  project_info.is_multimodule = true

                  for line in content:gmatch("[^\r\n]+") do
                    local subproject = line:match("include%s*%(?['\"]([^'\"]+)")
                    if subproject then
                      table.insert(project_info.subprojects, subproject)
                    end
                  end
                end
              elseif check.type == "maven" then
                project_info.is_maven = true
              end

              if content:match("spring%-boot") then
                project_info.is_spring_boot = true
              end

              local java_version = content:match("sourceCompatibility[%s=:]+['\"]?(%d+)")
                or content:match("java%.sourceCompatibility[%s=]+JavaVersion%.VERSION_(%d+)")
                or content:match("<java%.version>(%d+)</java%.version>")
              if java_version then
                project_info.java_version = java_version
              end

              break
            end
          end

          if is_monorepo then
            for _, subproject_path in ipairs(project_info.subprojects) do
              local subproject_build = workspace_root
                .. "/"
                .. subproject_path:gsub(":", "/")
                .. "/build.gradle"
              if vim.fn.filereadable(subproject_build) == 1 then
                local sub_content = table.concat(vim.fn.readfile(subproject_build), "\n")
                if sub_content:match("spring%-boot") then
                  project_info.is_spring_boot = true
                  break
                end
              end
            end
          end

          jdtls_cache[project_cache_key] = project_info
          print(
            "📊 Project analyzed: "
              .. (project_info.is_multimodule and "Monorepo" or "Single project")
              .. (project_info.is_spring_boot and " + Spring Boot" or "")
          )
        end

        local project_info = jdtls_cache[project_cache_key]

        local memory_config = "-Xmx2g"
        --if project_info.is_multimodule then
        --memory_config = "-Xmx3g"
        --elseif project_info.is_spring_boot then
        --memory_config = "-Xmx2g"
        --end

        local function get_java_executable()
          if jdtls_cache.java_executable then
            return jdtls_cache.java_executable
          end

          local sdkman_versions = { "24-tem", "21.0.1-tem", "23-tem", "22-tem" }
          local sdkman_base = os.getenv("HOME") .. "/.sdkman/candidates/java"

          for _, version in ipairs(sdkman_versions) do
            local java_exec = sdkman_base .. "/" .. version .. "/bin/java"
            if vim.fn.executable(java_exec) == 1 then
              jdtls_cache.java_executable = java_exec
              return java_exec
            end
          end

          local java_home = os.getenv("JAVA_HOME")
          if java_home and vim.fn.executable(java_home .. "/bin/java") == 1 then
            jdtls_cache.java_executable = java_home .. "/bin/java"
            return jdtls_cache.java_executable
          end

          jdtls_cache.java_executable = "java"
          return "java"
        end

        local bundles = {}
        if project_info.is_spring_boot then
          local spring_ls_path = jdtls_cache.paths.mason .. "/packages/spring-boot-tools"
          if vim.fn.isdirectory(spring_ls_path) == 1 then
            local spring_jars = vim.fn.glob(
              spring_ls_path .. "/extension/language-server/BOOT-INF/lib/*.jar",
              false,
              true
            )
            vim.list_extend(bundles, spring_jars)
          end
        end

        local workspace_folders = nil
        if project_info.is_multimodule then
          workspace_folders = { vim.uri_from_fname(workspace_root) }

          for _, subproject in ipairs(project_info.subprojects) do
            local subproject_path = workspace_root .. "/" .. subproject:gsub(":", "/")
            if vim.fn.isdirectory(subproject_path) == 1 then
              table.insert(workspace_folders, vim.uri_from_fname(subproject_path))
            end
          end
        end

        local config = {
          cmd = {
            get_java_executable(),
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-javaagent:" .. jdtls_cache.paths.jdtls .. "/lombok.jar",
            memory_config,
            "-Xms512m",
            "-XX:+UseParallelGC",
            "-XX:GCTimeRatio=4",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "--add-opens",
            "java.base/sun.nio.fs=ALL-UNNAMED",
            "-jar",
            jdtls_cache.launcher_jar,
            "-configuration",
            jdtls_cache.paths.jdtls .. "/" .. jdtls_cache.os_config,
            "-data",
            workspace_dir,
          },

          root_dir = workspace_root,

          settings = {
            java = {
              eclipse = {
                downloadSources = true,
              },
              configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                  {
                    name = "JavaSE-21",
                    path = os.getenv("HOME") .. "/.sdkman/candidates/java/21.0.1-tem/",
                    default = true,
                  },
                  {
                    name = "JavaSE-24",
                    path = os.getenv("HOME") .. "/.sdkman/candidates/java/24-tem/",
                  },
                },
              },
              maven = {
                downloadSources = true,
                updateSnapshots = false,
              },
              gradle = {
                enabled = project_info.is_gradle,
                wrapper = {
                  enabled = true,
                },
                buildServer = {
                  enabled = project_info.is_multimodule and "on" or "off",
                },
              },
              project = {
                referencedLibraries = {
                  "lib/**/*.jar",
                },
                outputPath = ".gradle/build",
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
                settings = {
                  profile = "GoogleStyle",
                },
              },
              saveActions = {
                organizeImports = true,
              },
              contentProvider = {
                preferred = "fernflower",
              },
              completion = {
                maxResults = 50,
                enabled = true,
                guessMethodArguments = true,
                favoriteStaticMembers = {
                  "org.hamcrest.MatcherAssert.assertThat",
                  "org.hamcrest.Matchers.*",
                  "org.junit.jupiter.api.Assertions.*",
                  "java.util.Objects.requireNonNull",
                  "org.mockito.Mockito.*",
                  project_info.is_spring_boot
                      and "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*"
                    or nil,
                  project_info.is_spring_boot
                      and "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*"
                    or nil,
                },
                importOrder = {
                  "java",
                  "javax",
                  "com",
                  "org",
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              autobuild = {
                enabled = true,
              },
              maxConcurrentBuilds = project_info.is_multimodule and 8 or 4, -- Mais builds paralelos para monorepos
              compile = {
                nullAnalysis = {
                  mode = "automatic",
                },
              },
              signatureHelp = {
                enabled = true,
                description = {
                  enabled = true,
                },
              },
              inlayHints = {
                parameterNames = {
                  enabled = "literals",
                },
              },
            },
            signatureHelp = { enabled = true },
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
          },

          init_options = {
            bundles = bundles,
            workspaceFolders = workspace_folders,
            settings = {
              java = {
                import = {
                  gradle = {
                    enabled = project_info.is_gradle,
                    wrapper = {
                      enabled = true,
                    },
                    version = nil, -- Auto-detect
                    home = nil, -- Auto-detect
                  },
                  maven = {
                    enabled = project_info.is_maven,
                  },
                },
              },
            },
          },

          capabilities = (function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            capabilities.workspace = capabilities.workspace or {}
            capabilities.workspace.workspaceEdit = capabilities.workspace.workspaceEdit or {}

            capabilities.workspace.workspaceFolders = true
            capabilities.workspace.workspaceEdit.resourceOperations =
              { "create", "rename", "delete" }
            capabilities.workspace.workspaceEdit.failureHandling = "abort"

            return capabilities
          end)(),

          on_attach = function(client, bufnr)
            jdtls_cache.active_workspace = workspace_dir

            local opts = { buffer = bufnr, silent = true }

            local keymaps = {
              { "n", "lgd", vim.lsp.buf.definition, { desc = "Go to definition" } },
              { "n", "lgD", vim.lsp.buf.declaration, { desc = "Go to declaration" } },
              { "n", "lgi", vim.lsp.buf.implementation, { desc = "Go to implementation" } },
              { "n", "lgr", vim.lsp.buf.references, { desc = "Go to references" } },
              { "n", "lgt", vim.lsp.buf.type_definition, { desc = "Go to type definition" } },
              { "n", "K", vim.lsp.buf.hover },
              { "n", "<C-k>", vim.lsp.buf.signature_help },
              { "n", "<leader>ca", vim.lsp.buf.code_action },
              { "n", "<leader>rn", vim.lsp.buf.rename },
              {
                "n",
                "<leader>f",
                function()
                  vim.lsp.buf.format({ async = true })
                end,
              },
              { "n", "[d", vim.diagnostic.goto_prev },
              { "n", "]d", vim.diagnostic.goto_next },
              {
                "n",
                "<leader>df",
                vim.diagnostic.open_float,
                { desc = "Open float diagnostics" },
              },
              { "n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Show warnings" } },

              { "n", "<leader>jo", jdtls.organize_imports, { desc = "Organize imports" } },
              { "n", "<leader>jv", jdtls.extract_variable, { desc = "Extract variable" } },
              { "n", "<leader>jc", jdtls.extract_constant, { desc = "Extract constant" } },
              {
                "v",
                "<leader>jm",
                [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                { desc = "Extract method" },
              },
            }

            for _, keymap in ipairs(keymaps) do
              vim.keymap.set(keymap[1], keymap[2], keymap[3], opts)
            end

            local group = vim.api.nvim_create_augroup("jdtls_" .. bufnr, { clear = true })

            if client.server_capabilities.documentHighlightProvider then
              local highlight_timer = nil
              vim.api.nvim_create_autocmd("CursorHold", {
                group = group,
                buffer = bufnr,
                callback = function()
                  if highlight_timer then
                    vim.fn.timer_stop(highlight_timer)
                  end
                  highlight_timer = vim.fn.timer_start(300, function()
                    vim.lsp.buf.document_highlight()
                  end)
                end,
              })

              vim.api.nvim_create_autocmd("CursorMoved", {
                group = group,
                buffer = bufnr,
                callback = function()
                  if highlight_timer then
                    vim.fn.timer_stop(highlight_timer)
                    highlight_timer = nil
                  end
                  vim.lsp.buf.clear_references()
                end,
              })
            end

            vim.bo[bufnr].shiftwidth = 2
            vim.bo[bufnr].tabstop = 2
            vim.bo[bufnr].expandtab = true

            local status_info = {
              "  JDTLS",
              is_monorepo and "  Monorepo" or "📁 Project",
              project_info.is_spring_boot and " Spring" or "",
              #project_info.subprojects > 0
                  and ("📦 " .. #project_info.subprojects .. " modules")
                or "",
            }

            print(table.concat(
              vim.tbl_filter(function(s)
                return s ~= ""
              end, status_info),
              " "
            ))
          end,
        }

        jdtls.start_or_attach(config)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          vim.defer_fn(setup_jdtls, 50)
        end,
      })

      vim.api.nvim_create_user_command("JdtlsRestart", function()
        jdtls_cache = {}
        require("jdtls").stop_client()
        vim.defer_fn(setup_jdtls, 1000)
        print("🔄 JDTLS restarted (shared workspace)")
      end, { desc = "Reinicia JDTLS" })

      vim.api.nvim_create_user_command("JdtlsWorkspaceInfo", function()
        local workspace_root, is_monorepo = find_monorepo_root()
        print("📁 Workspace root: " .. workspace_root)
        print("  Is monorepo: " .. (is_monorepo and "Yes" or "No"))

        if jdtls_cache.active_workspace then
          print("💾 Active workspace: " .. jdtls_cache.active_workspace)
        end
      end, { desc = "JDTLS workspace information" })
    end,
  },
}
