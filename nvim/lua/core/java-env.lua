local M = {}

function M.setup_java_env()
  local java_home = os.getenv("JAVA_HOME")

  if java_home and vim.fn.executable(java_home .. "/bin/java") == 1 then
    local version = vim.fn.system(java_home .. "/bin/java -version 2>&1")
    if version:match("21") or version:match("22") or version:match("23") or version:match("24") then
      return true
    end
  end

  local sdkman_base = os.getenv("HOME") .. "/.sdkman/candidates/java"

  if vim.fn.isdirectory(sdkman_base) == 1 then
    local preferred_versions = {
      "24-tem",
      "21.0.1-tem",
      "23-tem",
      "22-tem",
    }

    for _, version in ipairs(preferred_versions) do
      local java_path = sdkman_base .. "/" .. version
      local java_exec = java_path .. "/bin/java"

      if vim.fn.executable(java_exec) == 1 then
        vim.fn.setenv("JAVA_HOME", java_path)

        local current_path = os.getenv("PATH")
        local java_bin = java_path .. "/bin"

        if not current_path:find(java_bin, 1, true) then
          vim.fn.setenv("PATH", java_bin .. ":" .. current_path)
        end

        return true
      end
    end
  end

  print("⚠️  Java 21+ not found. JDTLS might not work.")
  print("💡 Install Java 21+ using SDKMAN: sdk install java 21.0.1-tem")
  return false
end

function M.java_info()
  local java_home = os.getenv("JAVA_HOME")

  print("☕ Java info:")
  print("======================")

  if java_home then
    print("JAVA_HOME: " .. java_home)

    local java_exec = java_home .. "/bin/java"
    if vim.fn.executable(java_exec) == 1 then
      local version = vim.fn.system(java_exec .. " -version 2>&1 | head -n 1")
      print("Version: " .. string.gsub(version, "\n", ""))

      if
        version:match("21")
        or version:match("22")
        or version:match("23")
        or version:match("24")
      then
        print("✅ Compatible with JDTLS")
      else
        print("❌ Incompatible (requires Java 21+)")
      end
    else
      print("❌ Java bin not found")
    end
  else
    print("❌ JAVA_HOME not defined")
  end

  if vim.fn.executable("java") == 1 then
    local path_version = vim.fn.system("java -version 2>&1 | head -n 1")
    print("Java in PATH: " .. string.gsub(path_version, "\n", ""))
  else
    print("❌ Java not found in PATH")
  end
end

function M.switch_java_version()
  local sdkman_base = os.getenv("HOME") .. "/.sdkman/candidates/java"

  if vim.fn.isdirectory(sdkman_base) == 1 then
    local versions = {}
    local handle = io.popen("ls " .. sdkman_base)

    if handle then
      for version in handle:lines() do
        local java_exec = sdkman_base .. "/" .. version .. "/bin/java"
        if vim.fn.executable(java_exec) == 1 then
          table.insert(versions, version)
        end
      end
      handle:close()
    end

    if #versions > 0 then
      vim.ui.select(versions, {
        prompt = "Select Java version:",
        format_item = function(item)
          return item
        end,
      }, function(choice)
        if choice then
          local java_path = sdkman_base .. "/" .. choice
          vim.fn.setenv("JAVA_HOME", java_path)

          local current_path = os.getenv("PATH")
          local java_bin = java_path .. "/bin"

          local new_path = {}
          for path_part in current_path:gmatch("[^:]+") do
            if not path_part:match("/java/[^/]+/bin") then
              table.insert(new_path, path_part)
            end
          end

          table.insert(new_path, 1, java_bin)
          vim.fn.setenv("PATH", table.concat(new_path, ":"))

          print("🔄 Java changed to: " .. choice)
          print("🔄 Restart JDTLS: :JdtlsRestart")
        end
      end)
    else
      print("❌ No Java version found in SDKMAN")
    end
  else
    print("❌ SDKMAN not found")
  end
end

M.setup_java_env()

vim.api.nvim_create_user_command("JavaInfo", M.java_info, {
  desc = "Current Java information",
})

vim.api.nvim_create_user_command("JavaSwitch", M.switch_java_version, {
  desc = "Switch Java version",
})

vim.api.nvim_create_user_command("JavaSetup", M.setup_java_env, {
  desc = "Configure Java environment automatically",
})

return M
