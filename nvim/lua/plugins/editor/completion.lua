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
      local symbol_headers = {}
      local lspkind_format = lspkind.cmp_format({
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
          Reference = " ",
          Folder = " ",
          File = " ",
        },
      })

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        performance = {
          debounce = 150,         -- Wait 150ms before triggering (was default 60ms)
          throttle = 60,          -- Throttle completions
          fetching_timeout = 200, -- Timeout faster
          max_view_entries = 50,  -- Limit visible entries
        },
        completion = {
          keyword_length = 2, -- Only trigger after 2 characters
          autocomplete = {
            cmp.TriggerEvent.TextChanged,
          },
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
        sources = cmp.config.sources({
          {
            name = "nvim_lsp",
            max_item_count = 30, -- Limit LSP items to reduce processing
            priority = 1000,
            entry_filter = function(entry)
              local item = entry:get_completion_item()

              -- Skip items with excessively long labels/details
              if item.label and #item.label > 60 then
                return false
              end

              return true
            end,
          },
          {
            name = "path",
            max_item_count = 10,
            priority = 500,
          },
          {
            name = "buffer",
            max_item_count = 10,
            priority = 250,
            keyword_length = 3,
          },
        }),
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = function(entry, vim_item)
            -- First apply the normal lspkind formatting
            vim_item = lspkind_format(entry, vim_item)

            if #vim_item.abbr > 40 then
              vim_item.abbr = vim_item.abbr:sub(1, 37) .. "..."
            end

            -- For LSP items, extract and show header information
            if entry.source.name == "nvim_lsp" then
              local item = entry:get_completion_item()
              local header = nil

              -- Method 1: Check labelDetails (newer LSP spec)
              if item.labelDetails and item.labelDetails.description then
                header = item.labelDetails.description:match("<([^>]+)>") or
                    item.labelDetails.description:match('"([^"]+)"')
              end

              -- Method 2: Check detail field (common in CCLS)
              if not header and item.detail then
                -- Try to extract header from various formats:
                -- Format: "Type -> header.h"
                header = item.detail:match("->%s*([%w/_.-]+%.h[px]*)")

                -- Format: "#include <header.h>"
                if not header then
                  header = item.detail:match("#include%s*<([^>]+)>") or
                      item.detail:match("#include%s*\"([^\"]+)\"")
                end

                -- Format: Just the header filename
                if not header then
                  header = item.detail:match("([%w/_.-]+%.h[px]*)$")
                end

                -- Format: Path with .h extension anywhere
                if not header then
                  for h in item.detail:gmatch("([%w/_.-]*%.h[px]*)") do
                    header = h
                    break
                  end
                end
              end

              -- Method 3: Check data field (CCLS specific)
              if not header and item.data then
                if type(item.data) == "table" and item.data.location then
                  local uri = item.data.location.uri
                  if uri then
                    header = uri:match("([^/]+%.h[px]*)$")
                  end
                end
              end

              -- Method 4: Check documentation
              if not header and item.documentation then
                local doc = type(item.documentation) == "string" and item.documentation or
                    (type(item.documentation) == "table" and item.documentation.value)
                if doc then
                  header = doc:match("#include%s*<([^>]+)>") or
                      doc:match("#include%s*\"([^\"]+)\"")
                end
              end

              if header then
                -- Clean up the header path (show only filename or key path)
                local short_header = header:match("([^/]+/[^/]+)$") or header:match("([^/]+)$") or header
                symbol_headers[item.label] = short_header
                vim_item.menu = vim_item.menu .. " [" .. short_header .. "]"
              elseif symbol_headers[item.label] then
                vim_item.menu = vim_item.menu .. " [" .. symbol_headers[item.label] .. "]"
              end
            end

            return vim_item
          end,
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
