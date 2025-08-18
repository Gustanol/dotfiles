return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        opts = {
            integrations = {
                render_markdown = true,
                markdown = true,
            },
            custom_highlights = function(colors)
                return {
                    RenderMarkdownH1 = { fg = colors.red, style = { "bold" } },
                    RenderMarkdownH1Bg = { bg = colors.surface0 },
                    RenderMarkdownH2 = { fg = colors.peach, style = { "bold" } },
                    RenderMarkdownH2Bg = { bg = colors.surface0 },
                    RenderMarkdownH3 = { fg = colors.yellow, style = { "bold" } },
                    RenderMarkdownH3Bg = { bg = colors.surface0 },
                    RenderMarkdownH4 = { fg = colors.green, style = { "bold" } },
                    RenderMarkdownH4Bg = { bg = colors.surface0 },
                    RenderMarkdownH5 = { fg = colors.sapphire, style = { "bold" } },
                    RenderMarkdownH5Bg = { bg = colors.surface0 },
                    RenderMarkdownH6 = { fg = colors.lavender, style = { "bold" } },
                    RenderMarkdownH6Bg = { bg = colors.surface0 },

                    RenderMarkdownChecked = { fg = colors.green },
                    RenderMarkdownUnchecked = { fg = colors.surface1 },
                    RenderMarkdownTodo = { fg = colors.yellow },

                    RenderMarkdownQuote = { fg = colors.surface2, bg = colors.surface0 },

                    RenderMarkdownCode = { bg = colors.surface0 },
                    RenderMarkdownCodeInline = { bg = colors.surface0, fg = colors.flamingo },

                    RenderMarkdownLink = { fg = colors.blue, style = { "underline" } },

                    RenderMarkdownInfo = { fg = colors.blue, bg = colors.surface0 },
                    RenderMarkdownSuccess = { fg = colors.green, bg = colors.surface0 },
                    RenderMarkdownHint = { fg = colors.teal, bg = colors.surface0 },
                    RenderMarkdownWarn = { fg = colors.yellow, bg = colors.surface0 },
                    RenderMarkdownError = { fg = colors.red, bg = colors.surface0 },

                    RenderMarkdownTableHead = { fg = colors.blue, style = { "bold" } },
                    RenderMarkdownTableRow = { fg = colors.text },

                    RenderMarkdownBullet = { fg = colors.blue },
                }
            end,
        },
    },
}
