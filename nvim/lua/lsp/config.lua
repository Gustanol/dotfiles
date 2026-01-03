local M = {}

M.capabilities = require("cmp_nvim_lsp").default_capabilities()

function M.on_attach(client, bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, {
      buffer = bufnr,
      silent = true,
      desc = desc,
    })
  end

  map("<leader>lgd", vim.lsp.buf.definition, "Go to definition")
  map("<leader>lgD", vim.lsp.buf.declaration, "Go to declaration")
  map("<leader>lgi", vim.lsp.buf.implementation, "Go to implementation")
  map("<leader>lgr", vim.lsp.buf.references, "Go to references")
  map("<leader>lgt", vim.lsp.buf.type_definition, "Go to type definition")

  map("K", function()
    vim.lsp.buf.hover {
      border = "single",
      max_width = 120,
      max_height = 30,
      title_pos = "left",
    }
  end, "Info")
  map("<C-k>", vim.lsp.buf.signature_help, "Help")

  map("<leader>lca", function()
    vim.lsp.buf.code_action({ apply = true })
  end, "Code actions")
  map("<leader>lrn", vim.lsp.buf.rename, "Rename")
  map("<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format file")
  map("<leader>lwa", vim.lsp.buf.add_workspace_folder, "Add folder to workspace")
  map("<leader>lwr", vim.lsp.buf.remove_workspace_folder, "Remove folder from workspace")
  map("<leader>lwl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List all workspace folders")

  map("[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, "Diagnostic: go to previous")

  map("]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, "Diagnostic: go to next")
  map("<leader>df", vim.diagnostic.open_float, "Diagnostic: open float")
  map("<leader>dq", vim.diagnostic.setloclist, "Diagnostic: Show warnings")

  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", {})
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

return M
