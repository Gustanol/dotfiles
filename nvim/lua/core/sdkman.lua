local M = {}

-- Função para detectar versões Java do SDKMAN
function M.get_sdkman_java_versions()
	local java_versions = {}
	local sdkman_java_path = os.getenv("HOME") .. "/.sdkman/candidates/java"

	-- Verifica se o diretório do SDKMAN existe
	local handle = io.popen("ls " .. sdkman_java_path .. " 2>/dev/null")
	if not handle then
		return java_versions
	end

	local result = handle:read("*a")
	handle:close()

	if result then
		for version in result:gmatch("[^\r\n]+") do
			-- Extrai o número da versão principal (11, 17, 21, etc.)
			local major_version = version:match("^(%d+)")
			if major_version then
				table.insert(java_versions, {
					name = "JavaSE-" .. major_version,
					path = sdkman_java_path .. "/" .. version,
					version = version,
				})
			end
		end
	end

	return java_versions
end

-- Função para obter a versão Java atual do SDKMAN
function M.get_current_java_version()
	local handle = io.popen("java -version 2>&1 | head -n 1")
	if not handle then
		return nil
	end

	local result = handle:read("*a")
	handle:close()

	-- Extrai versão do output (ex: "openjdk version "17.0.8"")
	local version = result:match('version "([^"]+)"')
	return version
end

-- Função para configurar JAVA_HOME se não estiver definido
function M.setup_java_home()
	local java_home = os.getenv("JAVA_HOME")

	if not java_home then
		local current_java = os.getenv("HOME") .. "/.sdkman/candidates/java/current"

		-- Verifica se o link current existe
		local handle = io.popen("test -L " .. current_java .. " && echo 'exists'")
		if handle then
			local result = handle:read("*a")
			handle:close()

			if result:match("exists") then
				vim.env.JAVA_HOME = current_java
				vim.notify("JAVA_HOME definido para: " .. current_java, vim.log.levels.INFO)
			end
		end
	else
		vim.notify("JAVA_HOME já definido: " .. java_home, vim.log.levels.INFO)
	end
end

-- Função para listar versões Java disponíveis
function M.list_java_versions()
	local versions = M.get_sdkman_java_versions()
	local current = M.get_current_java_version()

	print("Versões Java disponíveis via SDKMAN:")
	print("Versão atual: " .. (current or "Não detectada"))
	print("---")

	for _, version in ipairs(versions) do
		print(version.name .. " -> " .. version.path)
	end
end

-- Comando para trocar versão Java (opcional)
function M.switch_java_version(version)
	local cmd = "source ~/.sdkman/bin/sdkman-init.sh && sdk use java " .. version
	vim.fn.system(cmd)
	vim.notify("Mudando para Java " .. version .. " (reinicie o Neovim)", vim.log.levels.WARN)
end

-- Setup automático
function M.setup()
	M.setup_java_home()

	-- Comando para listar versões
	vim.api.nvim_create_user_command("JavaVersions", function()
		M.list_java_versions()
	end, { desc = "List Java versions from SDKMAN" })

	-- Comando para trocar versão (requer reinicialização do Neovim)
	vim.api.nvim_create_user_command("JavaUse", function(opts)
		if opts.args and opts.args ~= "" then
			M.switch_java_version(opts.args)
		else
			vim.notify("Uso: :JavaUse <versão>", vim.log.levels.ERROR)
		end
	end, {
		nargs = 1,
		desc = "Switch Java version using SDKMAN",
		complete = function()
			local versions = M.get_sdkman_java_versions()
			local version_names = {}
			for _, v in ipairs(versions) do
				table.insert(version_names, v.version)
			end
			return version_names
		end,
	})
end

return M
