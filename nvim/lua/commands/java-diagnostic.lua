local M = {}

-- Função para verificar e corrigir JAVA_HOME
function M.check_and_fix_java_home()
	local java_home = os.getenv("JAVA_HOME")

	if not java_home then
		local current_java = os.getenv("HOME") .. "/.sdkman/candidates/java/current"

		-- Verifica se current existe e é um link válido
		local handle = io.popen("test -L " .. current_java .. " && readlink " .. current_java)
		if handle then
			local real_path = handle:read("*a"):gsub("\n", "")
			handle:close()

			if real_path ~= "" then
				vim.env.JAVA_HOME = current_java
				print("✅ JAVA_HOME definido para: " .. current_java)
				return current_java
			end
		end

		print("❌ JAVA_HOME não encontrado e SDKMAN current não existe")
		return nil
	else
		print("✅ JAVA_HOME já definido: " .. java_home)
		return java_home
	end
end

-- Função para verificar se Java está funcionando
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
			print("✅ Java executável funcionando")
			print("   " .. result:match("([^\n]+)")) -- Primeira linha
			return true
		end
	end

	print("❌ Java executável não funciona")
	return false
end

-- Função para verificar workspace do jdtls
function M.check_jdtls_workspace()
	local home = os.getenv("HOME")
	local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_path = home .. "/.cache/jdtls/workspace/" .. workspace_dir

	-- Cria diretório se não existir
	vim.fn.mkdir(workspace_path, "p")

	print("✅ Workspace jdtls: " .. workspace_path)
	return workspace_path
end

-- Função para limpar workspace corrompido
function M.clean_jdtls_workspace()
	local home = os.getenv("HOME")
	local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_path = home .. "/.cache/jdtls/workspace/" .. workspace_dir

	print("🧹 Limpando workspace: " .. workspace_path)
	vim.fn.system("rm -rf " .. workspace_path)
	vim.fn.mkdir(workspace_path, "p")
	print("✅ Workspace limpo e recriado")
end

-- Função para verificar projeto Java
function M.check_java_project()
	local cwd = vim.fn.getcwd()

	print("📁 Verificando projeto Java em: " .. cwd)

	-- Verifica arquivos de build
	if vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
		print("✅ Projeto Maven detectado (pom.xml)")
		return "maven"
	elseif vim.fn.filereadable(cwd .. "/build.gradle") == 1 then
		print("✅ Projeto Gradle detectado (build.gradle)")
		return "gradle"
	elseif vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1 then
		print("✅ Projeto Gradle Kotlin detectado (build.gradle.kts)")
		return "gradle"
	end

	-- Verifica se há arquivos .java
	local java_files = vim.fn.glob("**/*.java")
	if java_files ~= "" then
		print("⚠️  Arquivos Java encontrados, mas sem arquivo de build")
		return "plain"
	end

	print("❌ Nenhum projeto Java detectado")
	return nil
end

-- Função principal de diagnóstico
function M.full_diagnostic()
	print("🔍 === DIAGNÓSTICO JAVA COMPLETO ===")
	print("")

	-- 1. Verifica JAVA_HOME
	local java_ok = M.check_java_executable()

	-- 2. Verifica projeto
	local project_type = M.check_java_project()

	-- 3. Verifica workspace
	M.check_jdtls_workspace()

	-- 4. Verifica LSP clients
	local clients = vim.lsp.get_clients({ name = "jdtls" })
	if #clients > 0 then
		print("✅ Cliente jdtls ativo")
		for _, client in ipairs(clients) do
			print("   Estado: " .. client.name .. " (ID: " .. client.id .. ")")
		end
	else
		print("❌ Nenhum cliente jdtls ativo")
	end

	-- 5. Verifica nvim-java
	local nvim_java_ok = pcall(require, "java")
	print((nvim_java_ok and "✅" or "❌") .. " nvim-java carregado: " .. tostring(nvim_java_ok))

	print("")
	print("📋 === RESUMO ===")

	if not java_ok then
		print("🔧 AÇÃO NECESSÁRIA: Execute :JavaFixJavaHome")
	end

	if not project_type then
		print("⚠️  AVISO: Não está em um projeto Java válido")
	end

	if #clients == 0 then
		print("🔧 AÇÃO NECESSÁRIA: Execute :JavaStart para iniciar jdtls")
	end

	print("")
end

-- Função para iniciar jdtls manualmente
function M.start_jdtls()
	print("🚀 Iniciando jdtls...")

	-- Para qualquer cliente existente
	local clients = vim.lsp.get_clients({ name = "jdtls" })
	for _, client in ipairs(clients) do
		client.stop()
	end

	-- Aguarda um pouco e inicia
	vim.defer_fn(function()
		vim.cmd("LspStart jdtls")
		print("✅ jdtls iniciado manualmente")
	end, 1000)
end

-- Função para correção automática
function M.auto_fix()
	print("🔧 Executando correção automática...")

	-- 1. Corrige JAVA_HOME
	M.check_and_fix_java_home()

	-- 2. Limpa workspace
	M.clean_jdtls_workspace()

	-- 3. Reinicia LSP
	vim.defer_fn(function()
		M.start_jdtls()
		print("✅ Correção automática concluída")
	end, 2000)
end

-- Setup de comandos
function M.setup()
	vim.api.nvim_create_user_command("JavaDiagnostic", M.full_diagnostic, { desc = "Diagnóstico completo Java" })
	vim.api.nvim_create_user_command("JavaStart", M.start_jdtls, { desc = "Iniciar jdtls manualmente" })
	vim.api.nvim_create_user_command("JavaFixJavaHome", M.check_and_fix_java_home, { desc = "Corrigir JAVA_HOME" })
	vim.api.nvim_create_user_command("JavaCleanWorkspace", M.clean_jdtls_workspace, { desc = "Limpar workspace jdtls" })
	vim.api.nvim_create_user_command("JavaAutoFix", M.auto_fix, { desc = "Correção automática Java" })
end

return M
