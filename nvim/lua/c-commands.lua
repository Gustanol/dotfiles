-- lua/c-commands.lua
-- Comandos personalizados para desenvolvimento em C

local M = {}

-- Função para criar um novo projeto C com estrutura básica
function M.create_c_project(project_name)
    project_name = project_name or vim.fn.input("Project name: ")
    if project_name == "" then
        return
    end

    -- Criar diretório do projeto
    vim.fn.mkdir(project_name, "p")
    vim.cmd("cd " .. project_name)

    -- Criar estrutura de diretórios
    vim.fn.mkdir("src", "p")
    vim.fn.mkdir("include", "p")
    vim.fn.mkdir("build", "p")
    vim.fn.mkdir("tests", "p")

    -- Criar Makefile básico
    local makefile_content = {
        "CC = gcc",
        "CFLAGS = -Wall -Wextra -std=c11 -g -I$(INCDIR)",
        "SRCDIR = src",
        "INCDIR = include",
        "BUILDDIR = build",
        "TARGET = " .. project_name,
        "",
        "SOURCES = $(wildcard $(SRCDIR)/*.c)",
        "OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)",
        "",
        ".PHONY: all clean",
        "",
        "all: $(BUILDDIR)/$(TARGET)",
        "",
        "$(BUILDDIR)/$(TARGET): $(OBJECTS)",
        "\t@mkdir -p $(BUILDDIR)",
        "\t$(CC) $(OBJECTS) -o $@",
        "",
        "$(BUILDDIR)/%.o: $(SRCDIR)/%.c",
        "\t@mkdir -p $(BUILDDIR)",
        "\t$(CC) $(CFLAGS) -c $< -o $@",
        "",
        "clean:",
        "\trm -rf $(BUILDDIR)",
        "",
        "run: $(BUILDDIR)/$(TARGET)",
        "\t./$(BUILDDIR)/$(TARGET)",
        "",
        "debug: $(BUILDDIR)/$(TARGET)",
        "\tgdb ./$(BUILDDIR)/$(TARGET)",
    }

    vim.fn.writefile(makefile_content, "Makefile")

    -- Criar compile_flags.txt para clangd
    local compile_flags = {
        "-std=c11",
        "-Wall",
        "-Wextra",
        "-pedantic",
        "-I.",
        "-Iinclude",
        "-xc",
    }
    vim.fn.writefile(compile_flags, "compile_flags.txt")

    -- Criar .clangd config
    local clangd_config = {
        "CompileFlags:",
        "  Add:",
        '    - "-std=c11"',
        '    - "-Wall"',
        '    - "-Wextra"',
        '    - "-Iinclude"',
        "  Remove:",
        '    - "-std=c++*"',
        "",
        "Index:",
        "  Background: Build",
        "",
        "Completion:",
        "  AllScopes: No",
        "",
        "Diagnostics:",
        "  UnusedIncludes: Strict",
        "  MissingIncludes: Strict",
    }
    vim.fn.writefile(clangd_config, ".clangd")

    -- Criar main.c básico
    local main_content = {
        "#include <stdio.h>",
        "#include <stdlib.h>",
        "#include <stdint.h>  /* Para uint32_t, etc. */",
        "",
        "int main(int argc, char *argv[]) {",
        '    printf("Hello, World!\\n");',
        "    return 0;",
        "}",
    }

    vim.fn.writefile(main_content, "src/main.c")

    -- Criar .gitignore
    local gitignore_content = {
        "build/",
        "*.o",
        "*.exe",
        "*.out",
        ".vscode/",
        "compile_commands.json",
        ".cache/",
    }

    vim.fn.writefile(gitignore_content, ".gitignore")

    -- Abrir o arquivo main.c
    vim.cmd("edit src/main.c")

    print("C project '" .. project_name .. "' created successfully with clangd configuration!")
end

-- Função para configurar clangd em projeto existente
function M.setup_clangd_for_c()
    -- Criar compile_flags.txt se não existir
    if vim.fn.filereadable("compile_flags.txt") == 0 then
        local compile_flags = {
            "-std=c11",
            "-Wall",
            "-Wextra",
            "-pedantic",
            "-I.",
            "-Iinclude",
            "-Isrc",
            "-xc",
        }
        vim.fn.writefile(compile_flags, "compile_flags.txt")
        print("Created compile_flags.txt")
    end

    -- Criar .clangd config se não existir
    if vim.fn.filereadable(".clangd") == 0 then
        local clangd_config = {
            "CompileFlags:",
            "  Add:",
            '    - "-std=c11"',
            '    - "-Wall"',
            '    - "-Wextra"',
            '    - "-I."',
            '    - "-Iinclude"',
            '    - "-Isrc"',
            "  Remove:",
            '    - "-std=c++*"',
            "",
            "Index:",
            "  Background: Build",
            "",
            "Completion:",
            "  AllScopes: No",
            "",
            "Diagnostics:",
            "  UnusedIncludes: Strict",
            "  MissingIncludes: Strict",
        }
        vim.fn.writefile(clangd_config, ".clangd")
        print("Created .clangd config")
    end

    -- Reiniciar LSP
    vim.cmd("LspRestart")
    print("Clangd configured for C. LSP restarted.")
end
function M.generate_compile_commands()
    if vim.fn.executable("bear") == 1 then
        vim.cmd("!bear -- make clean && bear -- make")
        print("compile_commands.json generated with bear")
    elseif vim.fn.filereadable("CMakeLists.txt") == 1 then
        vim.cmd("!cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build")
        vim.cmd("!ln -sf build/compile_commands.json .")
        print("compile_commands.json generated with CMake")
    else
        print("Install 'bear' or use CMake to generate compile_commands.json")
    end
end

-- Função para verificar sintaxe sem compilar
function M.syntax_check()
    local filename = vim.fn.expand("%")
    vim.cmd("!gcc -fsyntax-only -Wall -Wextra -std=c11 " .. filename)
end

-- Função para formatar código com clang-format
function M.format_code()
    if vim.fn.executable("clang-format") == 1 then
        vim.cmd("!clang-format -i --style='{BasedOnStyle: llvm, IndentWidth: 4, ColumnLimit: 100}' %")
        vim.cmd("edit!")
        print("Code formatted with clang-format")
    else
        print("clang-format not found")
    end
end

-- Função para executar análise estática
function M.static_analysis()
    local filename = vim.fn.expand("%")

    -- Usar clang-tidy se disponível (via clangd)
    if vim.fn.executable("clang-tidy") == 1 then
        vim.cmd("!clang-tidy " .. filename .. " -- -std=c11")
    elseif vim.fn.executable("cppcheck") == 1 then
        vim.cmd("!cppcheck --enable=all --std=c11 " .. filename)
    else
        -- Usar análise do clangd (built-in)
        vim.lsp.buf.code_action()
        print("Static analysis via clang-tidy or cppcheck not available. Using LSP code actions.")
    end
end

-- Função para criar header guard automaticamente
function M.create_header_guard()
    local filename = vim.fn.expand("%:t:r"):upper() .. "_H"
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    if #lines == 0 or (lines[1] ~= "#ifndef " .. filename) then
        local guard_lines = {
            "#ifndef " .. filename,
            "#define " .. filename,
            "",
        }

        -- Inserir no início
        vim.api.nvim_buf_set_lines(0, 0, 0, false, guard_lines)

        -- Adicionar no final
        vim.api.nvim_buf_set_lines(0, -1, -1, false, {
            "",
            "#endif /* " .. filename .. " */",
        })

        print("Header guard added")
    end
end

-- Registrar comandos
local function setup_commands()
    vim.api.nvim_create_user_command("CCreateProject", function(opts)
        M.create_c_project(opts.args)
    end, { nargs = "?", desc = "Create new C project" })

    vim.api.nvim_create_user_command(
        "CSetupClangd",
        M.setup_clangd_for_c,
        { desc = "Setup clangd configuration for C project" }
    )

    vim.api.nvim_create_user_command(
        "CGenerateCompileCommands",
        M.generate_compile_commands,
        { desc = "Generate compile_commands.json" }
    )

    vim.api.nvim_create_user_command("CSyntaxCheck", M.syntax_check, { desc = "Check syntax without compiling" })

    vim.api.nvim_create_user_command("CFormat", M.format_code, { desc = "Format code with clang-format" })

    vim.api.nvim_create_user_command("CAnalyze", M.static_analysis, { desc = "Run static analysis with clang-tidy" })

    vim.api.nvim_create_user_command(
        "CHeaderGuard",
        M.create_header_guard,
        { desc = "Add header guard to current file" }
    )
end

-- Configurar keymaps globais para C
local function setup_keymaps()
    local keymap = vim.keymap.set

    keymap("n", "<leader>cp", "<cmd>CCreateProject<cr>", { desc = "Create C Project" })
    keymap("n", "<leader>cs", "<cmd>CSetupClangd<cr>", { desc = "Setup Clangd for C" })
    keymap("n", "<leader>cg", "<cmd>CGenerateCompileCommands<cr>", { desc = "Generate compile_commands.json" })
    keymap("n", "<leader>cf", "<cmd>CFormat<cr>", { desc = "Format C code" })
    keymap("n", "<leader>ca", "<cmd>CAnalyze<cr>", { desc = "Analyze C code" })
end

-- Função de inicialização
function M.setup()
    setup_commands()
    setup_keymaps()
end

return M
