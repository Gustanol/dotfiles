return {
  -- Caso queira usar o fork ativo:
  -- "okuuva/auto-save.nvim",

  -- Ou o original:
  "Pocco81/auto-save.nvim",

  lazy = false,  -- carrega imediatamente (sem espera por comando/evento)
  config = function()
    require("auto-save").setup {
      enabled = true,
      execution_message = {
        message = function() return "AutoSave ✅ ".. vim.fn.strftime("%H:%M:%S") end,
        dim = 0.15,
        cleaning_interval = 1000,
      },
      trigger_events = {
        -- salva imediatamente quando sair do buffer ou perder foco
        immediate_save = { "BufLeave", "FocusLost" },
        -- ou salva com debounce após inserir texto ou deixar o modo de inserção
        defer_save     = { "InsertLeave", "TextChanged" },
        -- cancela debounce se voltar a inserir sem sair do insert
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = function(buf)
        -- não salva buffers especiais, de plugins ou com "readonly"
        local bt = vim.fn.getbufvar(buf, "&buftype")
        local ft = vim.fn.getbufvar(buf, "&filetype")
        return bt == "" and vim.bo[buf].modifiable and ft ~= "gitcommit"
      end,
      write_all_buffers = false,
      debounce_delay = 250,
      debug = false,
    }
  end,
}

