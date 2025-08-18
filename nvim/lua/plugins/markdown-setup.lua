return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            code = {
                style = "full",
                position = "left",
                language_pad = 0,
                disable_background = { "diff" },
            },
            heading = {
                icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
                backgrounds = {
                    "RenderMarkdownH1Bg",
                    "RenderMarkdownH2Bg",
                    "RenderMarkdownH3Bg",
                    "RenderMarkdownH4Bg",
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH6Bg",
                },
                foregrounds = {
                    "RenderMarkdownH1",
                    "RenderMarkdownH2",
                    "RenderMarkdownH3",
                    "RenderMarkdownH4",
                    "RenderMarkdownH5",
                    "RenderMarkdownH6",
                },
            },
            bullet = {
                icons = { "●", "○", "◆", "◇" },
            },
            checkbox = {
                unchecked = {
                    icon = "󰄱 ",
                    highlight = "RenderMarkdownUnchecked",
                },
                checked = {
                    icon = "󰱒 ",
                    highlight = "RenderMarkdownChecked",
                },
                custom = {
                    todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
                },
            },
            quote = {
                icon = "▋",
                highlight = "RenderMarkdownQuote",
            },
            pipe_table = {
                style = "full",
                cell = "padded",
                border = {
                    "┌",
                    "┬",
                    "┐",
                    "├",
                    "┼",
                    "┤",
                    "└",
                    "┴",
                    "┘",
                    "│",
                    "─",
                },
            },
            callout = {
                note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
                tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
                important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
                warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
                caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
            },
        },
        ft = { "markdown", "Avante" },
    },

    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
        config = function()
            vim.g.mkdp_theme = "dark"
            vim.g.mkdp_auto_start = 0
            vim.g.mkdp_auto_close = 1
            vim.g.mkdp_refresh_slow = 0
            vim.g.mkdp_command_for_global = 0
            vim.g.mkdp_open_to_the_world = 0
            vim.g.mkdp_open_ip = ""
            vim.g.mkdp_browser = ""
            vim.g.mkdp_echo_preview_url = 0
            vim.g.mkdp_browserfunc = ""
            vim.g.mkdp_preview_options = {
                mkit = {},
                katex = {},
                uml = {},
                maid = {},
                disable_sync_scroll = 0,
                sync_scroll_type = "middle",
                hide_yaml_meta = 1,
                sequence_diagrams = {},
                flowchart_diagrams = {},
                content_editable = false,
                disable_filename = 0,
                toc = {},
            }
            vim.g.mkdp_markdown_css = ""
            vim.g.mkdp_highlight_css = ""
            vim.g.mkdp_port = ""
            vim.g.mkdp_page_title = "「${name}」"
        end,
    },

    {
        "jakewvincent/mkdnflow.nvim",
        config = function()
            require("mkdnflow").setup({
                modules = {
                    bib = true,
                    buffers = true,
                    conceal = true,
                    cursor = true,
                    folds = true,
                    links = true,
                    lists = true,
                    maps = true,
                    paths = true,
                    tables = true,
                    yaml = false,
                },
                filetypes = { md = true, rmd = true, markdown = true },
                create_dirs = true,
                perspective = {
                    priority = "first",
                    fallback = "current",
                    root_tell = false,
                    nvim_wd_heel = false,
                    update = false,
                },
                wrap = false,
                bib = {
                    default_path = nil,
                    find_in_root = true,
                },
                silent = false,
                links = {
                    style = "markdown",
                    name_is_source = false,
                    conceal = false,
                    context = 0,
                    implicit_extension = nil,
                    transform_implicit = false,
                    transform_explicit = function(text)
                        text = text:gsub(" ", "-")
                        text = text:lower()
                        text = os.date("%Y-%m-%d_") .. text
                        return text
                    end,
                },
                new_file_template = {
                    use_template = false,
                    placeholders = {
                        before = {
                            title = "link_title",
                            date = "os_date",
                        },
                        after = {},
                    },
                    template = "# {{ title }}",
                },
                to_do = {
                    symbols = { " ", "-", "X" },
                    update_parents = true,
                    not_started = " ",
                    in_progress = "-",
                    complete = "X",
                },
                tables = {
                    trim_whitespace = true,
                    format_on_move = true,
                    auto_extend_rows = false,
                    auto_extend_cols = false,
                },
                yaml = {
                    bib = { override = false },
                },
                mappings = {
                    MkdnEnter = { { "n", "v" }, "<CR>" },
                    MkdnTab = false,
                    MkdnSTab = false,
                    MkdnNextLink = { "n", "<Tab>" },
                    MkdnPrevLink = { "n", "<S-Tab>" },
                    MkdnNextHeading = { "n", "]]" },
                    MkdnPrevHeading = { "n", "[[" },
                    MkdnGoBack = { "n", "<BS>" },
                    MkdnGoForward = { "n", "<Del>" },
                    MkdnCreateLink = false, -- see MkdnCreateLinkFromClipboard
                    MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>p" },
                    MkdnFollowLink = false, -- see MkdnEnter
                    MkdnDestroyLink = { "n", "<M-CR>" },
                    MkdnTagSpan = { "v", "<M-CR>" },
                    MkdnMoveSource = { "n", "<F2>" },
                    MkdnYankAnchorLink = { "n", "yaa" },
                    MkdnYankFileAnchorLink = { "n", "yfa" },
                    MkdnIncreaseHeading = { "n", "+" },
                    MkdnDecreaseHeading = { "n", "-" },
                    MkdnToggleToDo = { { "n", "v" }, "<C-Space>" },
                    MkdnNewListItem = false,
                    MkdnNewListItemBelowInsert = { "n", "o" },
                    MkdnNewListItemAboveInsert = { "n", "O" },
                    MkdnExtendList = false,
                    MkdnUpdateNumbering = { "n", "<leader>nn" },
                    MkdnTableNextCell = { "i", "<Tab>" },
                    MkdnTablePrevCell = { "i", "<S-Tab>" },
                    MkdnTableNextRow = false,
                    MkdnTablePrevRow = { "i", "<M-CR>" },
                    MkdnTableNewRowBelow = { "n", "<leader>ir" },
                    MkdnTableNewRowAbove = { "n", "<leader>iR" },
                    MkdnTableNewColAfter = { "n", "<leader>ic" },
                    MkdnTableNewColBefore = { "n", "<leader>iC" },
                    MkdnFoldSection = { "n", "<leader>f" },
                    MkdnUnfoldSection = { "n", "<leader>F" },
                },
            })
        end,
        ft = { "markdown" },
    },

    {
        "nvim-telescope/telescope.nvim",
        optional = true,
        keys = {
            {
                "<leader>fM",
                function()
                    require("telescope.builtin").find_files({
                        prompt_title = "Find Markdown Files",
                        find_command = { "find", ".", "-type", "f", "-name", "*.md" },
                    })
                end,
                desc = "Find Markdown Files",
            },
            {
                "<leader>sM",
                function()
                    require("telescope.builtin").live_grep({
                        prompt_title = "Search in Markdown",
                        type_filter = "md",
                    })
                end,
                desc = "Search in Markdown Files",
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            if type(opts.ensure_installed) == "table" and opts.ensure_installed ~= "all" then
                local function ensure_parsers(parsers)
                    for _, parser in ipairs(parsers) do
                        if not vim.tbl_contains(opts.ensure_installed, parser) then
                            table.insert(opts.ensure_installed, parser)
                        end
                    end
                end

                ensure_parsers({ "markdown", "markdown_inline" })
            end
        end,
    },

    {
        "KeitaNakamura/tex-conceal.vim",
        ft = { "markdown" },
        config = function()
            vim.g.tex_conceal = "abdmg"
            vim.g.tex_superscripts = "[0-9a-zA-W.,:;+-<>/()=]"
            vim.g.tex_subscripts = "[0-9aehijklmnoprstuvx,+-/().]"
        end,
    },
}
