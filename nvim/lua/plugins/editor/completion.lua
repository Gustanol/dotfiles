return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",           -- source for text in buffer
      "hrsh7th/cmp-path",             -- source for file system paths
      "hrsh7th/cmp-nvim-lsp",         -- source for LSP
      "hrsh7th/cmp-nvim-lua",         -- source for Lua API
      "hrsh7th/cmp-cmdline",          -- source for command line
      "saadparwaiz1/cmp_luasnip",     -- for autocompletion
      "rafamadriz/friendly-snippets", -- useful snippets
      "onsails/lspkind.nvim",         -- vs-code like pictograms
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,preview,noselect",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
          ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
          ["<C-e>"] = cmp.mapping.abort(),        -- close completion window
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp", priority = 1000 },                    -- LSP
          { name = "luasnip",  priority = 750 },                     -- snippets
          { name = "nvim_lua", priority = 700 },                     -- lua api
          { name = "buffer",   priority = 500, keyword_length = 3 }, -- text within current buffer
          { name = "path",     priority = 250 },                     -- file system paths
        },
        formatting = {
          format = lspkind.cmp_format({
            maxwidth = 50,
            ellipsis_char = "...",
            show_labelDetails = true,
            symbol_map = {
              Class = " ",
              Interface = " ",
              Enum = " ",
              EnumMember = " ",
              Method = " ",
              Function = "󰊕 ",
              Constructor = "󰣪 ",
              Field = " ",
              Variable = " ",
              Property = " ",
              Struct = " ",
              Union = "󰕤 ",
              TypeParameter = " ",
              Text = " ",
              Snippet = " ",
              Keyword = " ",
              Reference = "📎",
              Folder = " ",
              File = " ",
            },
          }),
        },
        window = {
          completion = cmp.config.window.bordered({
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            winhighlight = "Normal:CmpNormal,FloatBorder:CmpNormal,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocNormal,Search:None",
          }),
        },
        experimental = {
          ghost_text = true,
        },
        cmp.setup.filetype({ "c", "cpp" }, {
          sources = cmp.config.sources({
            { name = "nvim_lsp", priority = 1000 },
            { name = "luasnip",  priority = 750 },
            { name = "buffer",   priority = 500, keyword_length = 3 },
            { name = "path",     priority = 250 },
          }),
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")

      ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
        ext_opts = {
          [require("luasnip.util.types").choiceNode] = {
            active = {
              virt_text = { { "●", "GruvboxOrange" } },
            },
          },
        },
      })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true })

      vim.keymap.set("i", "<C-k>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end)

      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
