local M = {}

function M.check_and_fix_java_home()
  local java_home = os.getenv("JAVA_HOME")

  if not java_home then
    local current_java = os.getenv("HOME") .. "/.sdkman/candidates/java/current"

    local handle = io.popen("test -L " .. current_java .. " && readlink " .. current_java)
    if handle then
      local real_path = handle:read("*a"):gsub("\n", "")
      handle:close()

      if real_path ~= "" then
        vim.env.JAVA_HOME = current_java
        print("✅ JAVA_HOME defined to: " .. current_java)
        return current_java
      end
    end

    print("❌ JAVA_HOME not found & SDKMAN current does not exist")
    return nil
  else
    print("✅ JAVA_HOME already defined: " .. java_home)
    return java_home
  end
end

function M.check_java_executable()
  local java_home = M.check_and_fix_java_home()
  if not java_home then
    return false
  end

  local java_exe = java_home .. "/bin/java"
  local handle = io.popen(java_exe .. " -version 2>&1")

  if handle then
    local result = handle:read("*a")
    handle:close()

    if result:match("version") then
      print("✅ Java executable working")
      print("   " .. result:match("([^\n]+)"))
      return true
    end
  end

  print("❌ Java executable does not work")
  return false
end

function M.check_jdtls_workspace()
  local home = os.getenv("HOME")
  local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_path = home .. "/.cache/jdtls/workspace/" .. workspace_dir

  vim.fn.mkdir(workspace_path, "p")

  print("✅ JDTLS workspace: " .. workspace_path)
  return workspace_path
end

function M.clean_jdtls_workspace()
  local home = os.getenv("HOME")
  local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_path = home .. "/.cache/jdtls/workspace/" .. workspace_dir

  print("🧹 Cleaning workspace: " .. workspace_path)
  vim.fn.system("rm -rf " .. workspace_path)
  vim.fn.mkdir(workspace_path, "p")
  print("✅ Workspace recriated")
end

function M.check_java_project()
  local cwd = vim.fn.getcwd()

  print("📁 Verifying Java project in: " .. cwd)

  if vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
    print("✅ Maven project detected (pom.xml)")
    return "maven"
  elseif vim.fn.filereadable(cwd .. "/build.gradle") == 1 then
    print("✅ Gradle project detected (build.gradle)")
    return "gradle"
  elseif vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1 then
    print("✅ Gradle Kotlin project detected (build.gradle.kts)")
    return "gradle"
  end

  local java_files = vim.fn.glob("**/*.java")
  if java_files ~= "" then
    print("⚠️Java files found, but without build")
    return "plain"
  end

  print("❌ No Java project detected")
  return nil
end

function M.full_diagnostic()
  print("🔍 === Full Java Diagnostic ===")
  print("")

  local java_ok = M.check_java_executable()

  local project_type = M.check_java_project()

  M.check_jdtls_workspace()

  local clients = vim.lsp.get_clients({ name = "jdtls" })
  if #clients > 0 then
    print("✅ JDTLS client active")
    for _, client in ipairs(clients) do
      print("   State: " .. client.name .. " (ID: " .. client.id .. ")")
    end
  else
    print("❌ No active JDTLS clients")
  end

  local nvim_java_ok = pcall(require, "java")
  print((nvim_java_ok and "✅" or "❌") .. " nvim-java loaded: " .. tostring(nvim_java_ok))

  print("")
  print("📋 === Summary ===")

  if not java_ok then
    print("🔧 Needed action: Execute :JavaFixJavaHome")
  end

  if not project_type then
    print("⚠️  Warning: Not a valid Java project")
  end

  if #clients == 0 then
    print("🔧 Needed action: Execute :JavaStart to start JDTLS")
  end

  print("")
end

function M.start_jdtls()
  print("🚀 Initializing JDTLS...")

  local clients = vim.lsp.get_clients({ name = "jdtls" })
  for _, client in ipairs(clients) do
    client.stop()
  end

  vim.defer_fn(function()
    vim.cmd("LspStart jdtls")
    print("✅ JDTLS manually started")
  end, 1000)
end

function M.auto_fix()
  print("🔧 Executing automatic corrections...")

  M.check_and_fix_java_home()

  M.clean_jdtls_workspace()

  vim.defer_fn(function()
    M.start_jdtls()
    print("✅ Automatic correction concluded")
  end, 2000)
end

function M.setup()
  vim.api.nvim_create_user_command(
    "JavaDiagnostic",
    M.full_diagnostic,
    { desc = "Full Java Diagnostic" }
  )
  vim.api.nvim_create_user_command("JavaStart", M.start_jdtls, { desc = "Start JDTLS" })
  vim.api.nvim_create_user_command(
    "JavaFixJavaHome",
    M.check_and_fix_java_home,
    { desc = "Fix JAVA_HOME" }
  )
  vim.api.nvim_create_user_command(
    "JavaCleanWorkspace",
    M.clean_jdtls_workspace,
    { desc = "Clean JDTLS workspace" }
  )
  vim.api.nvim_create_user_command("JavaAutoFix", M.auto_fix, { desc = "Java auto fix" })
end

return M
