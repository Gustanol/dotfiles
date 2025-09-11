-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Options específicas para Java
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- Java specific
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.updatetime = 250
opt.timeoutlen = 300

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- Java memory settings
vim.env.JAVA_TOOL_OPTIONS = "-Xmx2G -XX:+UseG1GC"
