local M = {}

M.show_cheatsheet = function()
  local content = [[
╔══════════════════════════════════════════════════════════════╗
║              ASSEMBLY x86_64 CHEATSHEET                      ║
╚══════════════════════════════════════════════════════════════╝

[ AT&T SYNTAX ]
  movq %rax, rbx (rax -> rbx)

  • Registers has % prefix
  • Literals has $ prefix
  • Length suffix: b (byte), w (word), l (long), q (quad)

[ SOME SYSCALLS ]
  rax=0   read    (rdi=fd, rsi=buf, rdx=count)
  rax=1   write   (rdi=fd, rsi=buf, rdx=count)
  rax=2   open    (rdi=filename, rsi=flags, rdx=mode)
  rax=3   close   (rdi=fd)
  rax=60  exit    (rdi=status)

[ REGISTERS ]
  %rax - Acumulator, syscall number, return
  %rbx - Base
  %rcx - Counter
  %rdx - Data
  %rsi - Source index
  %rdi - Destination index
  %rbp - Base pointer
  %rsp - Stack pointer

[ ARGUMENTS ORDER ]
  Syscalls:     Others:
    1. %rax       1. %rdi
    2. %rdi       2. %rsi
    3. %rsi       3. %rdx
    4. %rdx       4. %rcx
    5. %r10       5. %r8
    6. %r8        6. %r9
    7. %r9

[ COMMON INSTRUCTIONS ]
  movq %src, %dst   - Cut/copy
  addq %src, %dst   - Add
  subq %src, %dst   - Sub
  mulq %src         - Multiply (%rax * src)
  divq %src         - Divide (%rax / src)
  incq %dst         - Increments
  decq %dst         - Decrements
  pushq %src
  popq %dst
  call label        - Call function
  ret               - Return
  syscall           - Call the syscall

[ LENGTH SUFFIXES ]
  b - byte    (8 bits)   - movb, addb
  w - word    (16 bits)  - movw, addw
  l - long    (32 bits)  - movl, addl
  q - quad    (64 bits)  - movq, addq

[ CONDITIONAL JUMPS ]
  js      - Jump if signed
  je/jz   - Jump if equal/zero
  jne/jnz - Jump if not equal/not zero
  jg/jnle - Jump if greater
  jge/jnl - Jump if greater or equal
  jl/jnge - Jump if less
  jle/jng - Jump if less or equal

[ MEMORY ADDRESSING ]
  (%rax)           - [rax]
  8(%rax)          - [rax+8]
  (%rax,%rbx)      - [rax+rbx]
  (%rax,%rbx,4)    - [rax+rbx*4]
  8(%rax,%rbx,4)   - [rax+rbx*4+8]

[ COMPARISONS ]
  cmpq %b, %a      - Compare (a - b)
  testq %b, %a     - Test bits (a & b)

[ DIRECTIVES ]
  .section .text  - Code section
  .section .data  - Initialized data section
  .section .bss   - Uninitialized data section
  .global symbol  - Global symbols
  .ascii "text"   - String ASCII (without \0)
  .asciz "text"   - String ASCII (with \0)
  .byte 10        - Byte
  .word 1000      - Word (2 bytes)
  .long 100000    - Long (4 bytes)
  .quad 10000000  - Quad (8 bytes)

[ PREPROCESSING (.S) ]
  #include <file> - Include file
  #define NAME v  - Define constant
  #ifdef NAME     - Conditional compilation

[ KEYMAPS ]
  <leader>ac  - Compile
  <leader>ar  - Execute
  <leader>ad  - Debug
  <leader>ab  - Toggle breakpoint
  <F5>        - Continue debug
  <F10>       - Step over
  <F11>       - Step into
  <F12>       - Step out
  <leader>as  - Show syscalls
  <leader>ag  - Show registers
  <leader>at  - Generate template
  <leader>ay  - Look for symbols
  <leader>an  - New project

[ COMMANDS ]
  :AsmCompile     - Compile current file
  :AsmRun         - Compile and execute
  :AsmDebug       - Compile and debug
  :AsmSyscalls    - Show syscalls
  :AsmRegisters   - Show registers
  :AsmTemplate    - Generate template
  :AsmSymbols     - Look for symbols
  :AsmNewProject  - New project

Press 'q' or <Esc> to close
]]

  local lines = vim.split(content, "\n")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  local width = 70
  local height = math.min(#lines, vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " GAS Cheatsheet ",
    title_pos = "center",
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
end

return M
