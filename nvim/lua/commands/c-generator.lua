local M = {}

function M.compile_current()
	local file = vim.fn.expand("%")
	local file_no_ext = vim.fn.expand("%:t:r")

	if vim.fn.expand("%:e") ~= "c" then
		vim.notify("Not a C file!", vim.log.levels.ERROR)
		return
	end

	local cmd = string.format("gcc -Wall -Wextra -std=c11 -g -o %s %s", file_no_ext, file)

	vim.fn.jobstart(cmd, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify(string.format("✓ Compiled successfully: %s", file_no_ext), vim.log.levels.INFO)
			else
				vim.notify("✗ Compilation failed!", vim.log.levels.ERROR)
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data and #data > 1 then
				vim.schedule(function()
					vim.cmd("copen")
					vim.fn.setqflist({}, "r", { lines = data })
				end)
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 1 then
				vim.schedule(function()
					vim.cmd("copen")
					vim.fn.setqflist({}, "r", { lines = data })
				end)
			end
		end,
	})
end

function M.run_current()
	local file_no_ext = vim.fn.expand("%:t:r")
	local executable = "./" .. file_no_ext

	if vim.fn.filereadable(executable) == 0 then
		vim.notify("Executable not found. Compile first!", vim.log.levels.WARN)
		M.compile_current()
		return
	end

	vim.cmd("split")
	vim.cmd("terminal " .. executable)
	vim.cmd("startinsert")
end

function M.make_project()
	if vim.fn.filereadable("Makefile") == 1 or vim.fn.filereadable("makefile") == 1 then
		vim.cmd("make")
	else
		vim.notify("No Makefile found!", vim.log.levels.WARN)
	end
end

function M.debug_current()
	local file_no_ext = vim.fn.expand("%:t:r")
	local executable = "./" .. file_no_ext

	if vim.fn.filereadable(executable) == 0 then
		vim.notify("Executable not found. Compile first!", vim.log.levels.WARN)
		return
	end

	require("dap").run({
		type = "codelldb",
		request = "launch",
		name = "Debug " .. file_no_ext,
		program = vim.fn.getcwd() .. "/" .. file_no_ext,
		cwd = vim.fn.getcwd(),
	})
end

-- Toggle between header and source
function M.toggle_header_source()
	local current_file = vim.fn.expand("%")
	local file_ext = vim.fn.expand("%:e")
	local file_base = vim.fn.expand("%:t:r")

	local target_file

	if file_ext == "c" then
		target_file = file_base .. ".h"
	elseif file_ext == "h" then
		target_file = file_base .. ".c"
	else
		vim.notify("Not a C file!", vim.log.levels.WARN)
		return
	end

	-- Search in current directory first
	if vim.fn.filereadable(target_file) == 1 then
		vim.cmd("edit " .. target_file)
		return
	end

	-- Search in common directories
	local search_dirs = { "src/", "include/", "inc/", "../src/", "../include/", "../inc/" }

	for _, dir in ipairs(search_dirs) do
		local full_path = dir .. target_file
		if vim.fn.filereadable(full_path) == 1 then
			vim.cmd("edit " .. full_path)
			return
		end
	end

	-- If not found, create it
	local choice = vim.fn.confirm("File " .. target_file .. " not found. Create it?", "&Yes\n&No", 1)
	if choice == 1 then
		vim.cmd("edit " .. target_file)

		if file_ext == "c" then
			-- Creating header file
			M.add_include_guard()
		else
			-- Creating source file
			vim.api.nvim_buf_set_lines(0, 0, -1, false, {
				'#include "' .. file_base .. '.h"',
				"",
				"",
			})
		end
	end
end

-- Add include guard to header file
function M.add_include_guard()
	local file_name = vim.fn.expand("%:t:r"):upper() .. "_H"
	local guard_name = file_name:gsub("[^%w]", "_")

	local lines = {
		"#ifndef " .. guard_name,
		"#define " .. guard_name,
		"",
		"",
		"",
		"#endif /* " .. guard_name .. " */",
	}

	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.api.nvim_win_set_cursor(0, { 4, 0 })
end

-- Find functions in current file
function M.find_functions()
	require("telescope.builtin").grep_string({
		search = "^[a-zA-Z_][a-zA-Z0-9_]*\\s*[a-zA-Z_][a-zA-Z0-9_]*\\s*\\([^)]*\\)\\s*{",
		use_regex = true,
		search_dirs = { vim.fn.expand("%") },
		prompt_title = "Functions in " .. vim.fn.expand("%:t"),
	})
end

-- Lint current file
function M.lint_file()
	local file = vim.fn.expand("%")
	local cmd = "cppcheck --enable=all --std=c11 " .. file

	vim.fn.jobstart(cmd, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify("✓ No issues found", vim.log.levels.INFO)
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
		on_stderr = function(_, data)
			if data and #data > 1 then
				vim.schedule(function()
					vim.cmd("copen")
					vim.fn.setqflist({}, "r", { lines = data })
				end)
			end
		end,
	})
end

-- Run tests (looks for test files)
function M.run_tests()
	local test_files = vim.fn.glob("test*.c", false, true)

	if #test_files == 0 then
		test_files = vim.fn.glob("*test.c", false, true)
	end

	if #test_files == 0 then
		vim.notify("No test files found!", vim.log.levels.WARN)
		return
	end

	for _, test_file in ipairs(test_files) do
		local test_name = vim.fn.fnamemodify(test_file, ":t:r")
		local compile_cmd = string.format("gcc -Wall -Wextra -std=c11 -g -o %s %s", test_name, test_file)

		vim.fn.jobstart(compile_cmd, {
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					vim.fn.jobstart("./" .. test_name, {
						on_exit = function(_, test_exit_code)
							if test_exit_code == 0 then
								vim.notify("✓ Test passed: " .. test_name, vim.log.levels.INFO)
							else
								vim.notify("✗ Test failed: " .. test_name, vim.log.levels.ERROR)
							end
						end,
					})
				else
					vim.notify("✗ Failed to compile test: " .. test_name, vim.log.levels.ERROR)
				end
			end,
		})
	end
end

-- Create new C project
function M.create_c_project()
	local project_name = vim.fn.input("Project name: ")

	if project_name == "" then
		return
	end

	-- Create directory structure
	local dirs = {
		project_name,
		project_name .. "/src",
		project_name .. "/include",
		project_name .. "/tests",
		project_name .. "/build",
	}

	for _, dir in ipairs(dirs) do
		vim.fn.mkdir(dir, "p")
	end

	-- Create main.c
	local main_content = {
		"#include <stdio.h>",
		"",
		"int main(int argc, const char *argv[]) {",
		'    printf("Hello, ' .. project_name .. '!\\n");',
		"    return 0;",
		"}",
	}

	vim.fn.writefile(main_content, project_name .. "/src/main.c")

	-- Create header file
	local header_guard = project_name:upper() .. "_H"
	local header_content = {
		"#ifndef " .. header_guard,
		"#define " .. header_guard,
		"",
		"// Function declarations",
		"",
		"#endif /* " .. header_guard .. " */",
	}

	vim.fn.writefile(header_content, project_name .. "/include/" .. project_name .. ".h")

	-- Create Makefile
	local makefile_content = {
		"CC=gcc",
		"CFLAGS=-Wall -Wextra -std=c11 -g",
		"SRCDIR=src",
		"INCDIR=include",
		"BUILDDIR=build",
		"TARGET=" .. project_name,
		"",
		"SOURCES=$(wildcard $(SRCDIR)/*.c)",
		"OBJECTS=$(SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)",
		"",
		".PHONY: all clean",
		"",
		"all: $(TARGET)",
		"",
		"$(TARGET): $(OBJECTS)",
		"\t$(CC) $(OBJECTS) -o $@",
		"",
		"$(BUILDDIR)/%.o: $(SRCDIR)/%.c",
		"\t@mkdir -p $(BUILDDIR)",
		"\t$(CC) $(CFLAGS) -I$(INCDIR) -c $< -o $@",
		"",
		"clean:",
		"\trm -rf $(BUILDDIR) $(TARGET)",
		"",
		"test: $(TARGET)",
		"\t./$(TARGET)",
	}

	vim.fn.writefile(makefile_content, project_name .. "/Makefile")

	local dotclangd_content = {
		"CompileFlags:",
		"Add:",
		'- "-std=c11"',
		'- "-Wall"',
		'- "-Wextra"',
		'- "-pedantic"',
		'- "-D_GNU_SOURCE"',
		"Remove:",
		'- "-W*"',
		'- "-std=c++*"',
		"",
		"Index:",
		"Background: Build",
		"StandardLibrary: Yes",
		"",
		"InlayHints:",
		"Enabled: Yes",
		"ParameterNames: Yes",
		"DeducedTypes: Yes",
		"",
		"Hover:",
		"ShowAKA: Yes",
		"",
		"Completion:",
		"AllScopes: No",
		"",
		"Diagnostics:",
		"ClangTidy:",
		"Add:",
		'- "readability-*"',
		'- "bugprone-*"',
		'- "performance-*"',
		'- "portability-*"',
		"Remove:",
		'- "readability-braces-around-statements"',
		'- "bugprone-easily-swappable-parameters"',
		"UnusedIncludes: Strict",
		"MissingIncludes: Strict",
	}

	vim.fn.writefile(dotclangd_content, project_name .. "/.clangd")

	local compile_flags_content = {
		"-std=c11",
		"-Wall",
		"-Wextra",
		"-pedantic",
		"-I.",
		"-Iinclude",
		"-xc",
		"-D_GNU_SOURCE",
	}

	vim.fn.writefile(compile_flags_content, project_name .. "/compile_flags.txt")

	-- Create README
	local readme_content = {
		"# " .. project_name,
		"",
		"## Build",
		"",
		"```bash",
		"make",
		"```",
		"",
		"## Run",
		"",
		"```bash",
		"./" .. project_name,
		"```",
		"",
		"## Clean",
		"",
		"```bash",
		"make clean",
		"```",
	}

	vim.fn.writefile(readme_content, project_name .. "/README.md")

	-- create .gitignore file
	local dotgitignore_content = {
		"build/",
		"*.o",
		"*.exe",
		"*.out",
		".vscode/",
		"compile_commands.json",
		".cache/",
		"*.img",
	}

	vim.fn.writefile(dotgitignore_content, project_name .. "/.gitignore")

	-- Open project
	vim.cmd("cd " .. project_name)
	vim.cmd("edit src/main.c")

	vim.notify("✓ C project created: " .. project_name, vim.log.levels.INFO)
end

return M
