local M = {}

M.current_arch = "x86_64"

M.syscalls_x64 = {
  { num = 0, name = "sys_read",  args = "unsigned int fd, char *buf, size_t count" },
  { num = 1, name = "sys_write", args = "unsigned int fd, const char *buf, size_t count" },
  { num = 2, name = "sys_open",  args = "const char *filename, int flags, umode_t mode" },
  { num = 3, name = "sys_close", args = "unsigned int fd" },
  { num = 4, name = "sys_stat",  args = "unsigned int fd, struct stat *statbuf" },
  { num = 5, name = "sys_fstat", args = "const char *filename, struct stat *statbuf" },
  { num = 6, name = "sys_lstat", args = "const char *filename, struct stat *statbuf" },
  {
    num = 9,
    name = "sys_mmap",
    args =
    "unsigned long addr, unsigned long len, unsigned long prot, unsigned long flags, unsigned long fd, unsigned long off",
  },
  { num = 11, name = "sys_mumap", args = "unsigned long addr, size_t len" },
  { num = 60, name = "sys_exit",  args = "int error_code" },
  { num = 57, name = "sys_fork",  args = "void" },
  {
    num = 59,
    name = "sys_execve",
    args = "const char *filename, char *const argv[], char *const envp[]",
  },
}

M.registers_x64 = {
  general = {
    "RAX - Acumulator, function return, syscall number",
    "RBX - Base register",
    "RCX - Counter, 4º argument",
    "RDX - Data, 3º argument",
    "RSI - Source index, 2º argument",
    "RDI - Destination index, 1º argument",
    "RBP - Base pointer (stack frame)",
    "RSP - Stack pointer",
    "R8-R15 - General purpose registers",
  },
  special = {
    "RIP - Instruction pointer",
    "RFLAGS - Flags register (CF, ZF, SF, OF, etc.)",
  },
  segment = {
    "CS - Code segment",
    "DS - Data segment",
    "SS - Stack segment",
    "ES, FS, GS - Extra segments",
  },
}

M.show_syscalls = function()
  local lines = { "=== Linux x86_64 Syscalls ===" }
  table.insert(lines, "")

  for _, syscall in ipairs(M.syscalls_x64) do
    table.insert(lines, string.format("%3d | %-15s | %s", syscall.num, syscall.name, syscall.args))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  local width = 100
  local height = 20
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Syscalls ",
    title_pos = "center",
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
end

M.show_registers = function()
  local lines = { "=== x86_64 registers ===" }
  table.insert(lines, "")
  table.insert(lines, "[ General registers ]")
  for _, reg in ipairs(M.registers_x64.general) do
    table.insert(lines, "  • " .. reg)
  end

  table.insert(lines, "")
  table.insert(lines, "[ Special registers ]")
  for _, reg in ipairs(M.registers_x64.special) do
    table.insert(lines, "  • " .. reg)
  end

  table.insert(lines, "")
  table.insert(lines, "[ Segment registers ]")
  for _, reg in ipairs(M.registers_x64.segment) do
    table.insert(lines, "  • " .. reg)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  local width = 80
  local height = 25
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Registers ",
    title_pos = "center",
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
end

M.create_project = function()
  local project_name = vim.fn.input("Project name: ")
  if project_name == "" then
    vim.notify("Invalid name", vim.log.levels.ERROR)
    return
  end

  local arch = vim.fn.input("Architecture (32/64): ", "64")
  local project_dir = vim.fn.getcwd() .. "/" .. project_name

  vim.fn.mkdir(project_dir, "p")
  vim.fn.mkdir(project_dir .. "/src", "p")
  vim.fn.mkdir(project_dir .. "/build", "p")

  local main_content
  if arch == "32" then
    main_content = [[.section .data

.section .text
    .global _start

_start:
]]
  else
    main_content = [[.section .data
.section .text
    .global _start

_start:
]]
  end

  vim.fn.writefile(vim.split(main_content, "\n"), project_dir .. "/src/main.s")

  local makefile_content
  if arch == "32" then
    makefile_content = [[
AS = as
ASFLAGS = --32 -g
LD = ld
LDFLAGS = -m elf_i386

SRC_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)/program

SOURCES = $(wildcard $(SRC_DIR)/*.s)
OBJECTS = $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SOURCES))

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

run: $(TARGET)
	$(TARGET)

debug: $(TARGET)
	gdb $(TARGET)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug clean
]]
  else
    makefile_content = [[
AS = as
ASFLAGS = -g
LD = ld
LDFLAGS =

SRC_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)/program

SOURCES = $(wildcard $(SRC_DIR)/*.s)
OBJECTS = $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SOURCES))

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

run: $(TARGET)
	$(TARGET)

debug: $(TARGET)
	gdb $(TARGET)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug clean
]]
  end

  vim.fn.writefile(vim.split(makefile_content, "\n"), project_dir .. "/Makefile")

  local gitignore_content = [[# Build artifacts
build/
*.o
*.out
*.exe

# Debug files
*.dwarf
*.dSYM/

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
]]

  vim.fn.writefile(vim.split(gitignore_content, "\n"), project_dir .. "/.gitignore")

  local readme_content = string.format(
    [[# %s

### Project structure

```plaintext
%s/
├── src/           # Source files (.s)
├── build/         # Build artifacts
├── Makefile       # Build configuration
└── README.md      # This file
```

### How to run this?
Build
```bash
make all
```

Run
```bash
make run
```

Debug
```bash
make debug
```

Clean
```bash
make clean
```
]],
    project_name,
    arch,
    project_name
  )

  vim.fn.writefile(vim.split(readme_content, "\n"), project_dir .. "/readme.md")

  local editorconfig_content = [[root = true
[*.s]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.S]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[Makefile]
indent_style = tab
]]

  vim.fn.writefile(vim.split(editorconfig_content, "\n"), project_dir .. "/.editorconfig")

  vim.notify("✓ Project created: " .. project_dir, vim.log.levels.INFO)
  vim.cmd("cd " .. project_dir)
  vim.cmd("edit src/main.s")
end

-- Jump to include file (supports both #include and .include)
M.goto_include = function()
  local line = vim.api.nvim_get_current_line()

  -- Match various include formats
  local include_file = line:match('#include%s+"([^"]+)"') or
      line:match("#include%s+<([^>]+)>") or
      line:match('%.include%s+"([^"]+)"')

  if include_file then
    local resolved = require("core.asm-includes").resolve_include(include_file)

    local ok = pcall(function()
      return vim.cmd
    end, "edit " .. vim.fn.fnameescape(resolved))
    if not ok then
      vim.notify("Include file not found: " .. include_file, vim.log.levels.WARN)
    end
  else
    -- Fallback to vim's gf
    vim.cmd("normal! gf")
  end
end

return M
