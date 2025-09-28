return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      c = { "cppcheck" },
      cpp = { "cppcheck" },

      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },

      python = { "pylint" },

      lua = { "luacheck" },

      sh = { "shellcheck" },
      bash = { "shellcheck" },

      yaml = { "yamllint" },

      dockerfile = { "hadolint" },

      makefile = { "makecheck" },

      markdown = { "markdownlint" },
    }

    lint.linters.cppcheck.args = {
      "--enable=all",
      "--suppress=missingIncludeSystem",
      "--suppress=unmatchedSuppression",
      "--suppress=unusedFunction",
      "--inline-suppr",
      "--quiet",
      "--template=gcc",
      "--std=c11",
    }

    lint.linters.luacheck.args = {
      "--globals",
      "vim",
      "--no-unused-args",
      "--formatter",
      "plain",
      "--codes",
      "--ranges",
      "-",
    }

    lint.linters.shellcheck.args = {
      "--format=json",
      "-",
    }

    local function lint_current_file()
      lint.try_lint()
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.filetype ~= "java" then
          lint_current_file()
        end
      end,
    })

    vim.api.nvim_create_user_command("Lint", function()
      lint_current_file()
    end, { desc = "Execute linters to the current file" })

    vim.api.nvim_create_user_command("LintInfo", function()
      local filetype = vim.bo.filetype
      local linters = lint.linters_by_ft[filetype] or {}

      if #linters == 0 then
        print("No configured linters: " .. filetype)
      else
        print("Linters for " .. filetype .. ": " .. table.concat(linters, ", "))
      end
    end, { desc = "Current linters info" })

    vim.keymap.set("n", "<leader>l", lint_current_file, {
      desc = "Execute linting",
      silent = true,
    })
  end,
}
