return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local c = ls.choice_node

    ls.add_snippets("gas", {
      s("prog64", {
        t({ ".section .data", "    " }),
        i(1, "# initialization"),
        t({ "", "", ".section .bss", "    " }),
        i(2, "# uninitialized variables"),
        t({ "", "", ".section .text", "    .global _start", "", "_start:", "    " }),
        i(3, "# code here"),
        t({ "", "", "    # exit(0)", "    movq $60, %rax", "    xorq %rdi, %rdi", "    syscall" }),
      }),

      s("prog32", {
        t({ ".section .data", "    " }),
        i(1, "# initialization"),
        t({ "", "", ".section .bss", "    " }),
        i(2, "# uninitialized variables"),
        t({ "", "", ".section .text", "    .global _start", "", "_start:", "    " }),
        i(3, "# code here"),
        t({ "", "", "    # exit(0)", "    movl $1, %eax", "    xorl %ebx, %ebx", "    int $0x80" }),
      }),

      s("func", {
        t({ "" }),
        i(1, "function_name"),
        t({ ":" }),
        t({ "", "    pushq %rbp", "    movq %rsp, %rbp" }),
        t({ "", "    " }),
        i(2, "# ..."),
        t({ "", "    movq %rbp, %rsp", "    popq %rbp", "    ret", "" }),
      }),

      s("print", {
        t({ "movq $1, %rax        # sys_write" }),
        t({ "", "movq $1, %rdi        # stdout" }),
        t({ "", "movq $" }),
        i(1, "message"),
        t({ ", %rsi  # buffer" }),
        t({ "", "movq $" }),
        i(2, "msg_len"),
        t({ ", %rdx  # length" }),
        t({ "", "syscall" }),
      }),

      s("read", {
        t({ "movq $0, %rax        # sys_read" }),
        t({ "", "movq $0, %rdi        # stdin" }),
        t({ "", "movq $" }),
        i(1, "buffer"),
        t({ ", %rsi   # buffer" }),
        t({ "", "movq $" }),
        i(2, "buf_size"),
        t({ ", %rdx # size" }),
        t({ "", "syscall" }),
      }),

      s("loop", {
        t({ "    movq $" }),
        i(1, "10"),
        t({ ", %rcx  # counter" }),
        t({ "", "." }),
        i(2, "loop_label"),
        t({ ":" }),
        t({ "", "    " }),
        i(3, "# loop body"),
        t({ "", "    loop ." }),
        f(function(args)
          return args[1][1]
        end, { 2 }),
      }),

      s("cmp", {
        t({ "cmpq $" }),
        i(2, "0"),
        t({ ", %" }),
        i(1, "rax"),
        t({ "", "" }),
        c(3, {
          t("je"),
          t("jne"),
          t("jg"),
          t("jge"),
          t("jl"),
          t("jle"),
        }),
        t({ " ." }),
        i(4, "label"),
      }),

      s("str", {
        i(1, "msg"),
        t({ ":" }),
        t({ "", '    .ascii "' }),
        i(2, "value"),
        t({ '"' }),
        t({ "", "    " }),
        f(function(args)
          return args[1][1] .. "_len"
        end, { 1 }),
        t({ " = . - " }),
        f(function(args)
          return args[1][1]
        end, { 1 }),
      }),

      s("syscall", {
        t({ "movq $" }),
        i(1, "syscall_number"),
        t({ ", %rax" }),
        t({ "", "movq $" }),
        i(2, "arg1"),
        t({ ", %rdi" }),
        t({ "", "movq $" }),
        i(3, "arg2"),
        t({ ", %rsi" }),
        t({ "", "movq $" }),
        i(4, "arg3"),
        t({ ", %rdx" }),
        t({ "", "syscall" }),
      }),

      s("if", {
        t({ "cmpq $" }),
        i(2, "0"),
        t({ ", %" }),
        i(1, "rax"),
        t({ "", "jne ." }),
        i(3, "else_label"),
        t({ "", "    " }),
        i(4, "# if"),
        t({ "", "    jmp ." }),
        i(5, "end_label"),
        t({ "", "." }),
        f(function(args)
          return args[1][1]
        end, { 3 }),
        t({ ":" }),
        t({ "", "    " }),
        i(6, "# else body"),
        t({ "", "." }),
        f(function(args)
          return args[1][1]
        end, { 5 }),
        t({ ":" }),
      }),

      s("macro", {
        t({ "#define " }),
        i(1, "MACRO_NAME"),
        t({ "(" }),
        i(2, "args"),
        t({ ") \\" }),
        t({ "", "    " }),
        i(3, "# macro body"),
      }),

      s("pushmany", {
        t({ "pushq %" }),
        i(1, "rbx"),
        t({ "", "pushq %" }),
        i(2, "rcx"),
        t({ "", "pushq %" }),
        i(3, "rdx"),
      }),

      s("popmany", {
        t({ "popq %" }),
        i(3, "rdx"),
        t({ "", "popq %" }),
        i(2, "rcx"),
        t({ "", "popq %" }),
        i(1, "rbx"),
      }),
    })

    ls.add_snippets("asm", ls.get_snippets("gas"))
  end,
}
