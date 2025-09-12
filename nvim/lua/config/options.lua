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

-- Auto-save related
vim.opt.autowrite = true -- Enable auto write
vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer
vim.opt.autoread = true -- Auto reload files changed outside vim

-- Buffer related
vim.opt.hidden = true -- Enable background buffers
vim.opt.splitkeep = "screen" -- Maintain screen position when splitting

-- Backup and swap
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Session options
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Better display
vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.opt.showcmd = false -- Don't show command in the last line

-- File detection
vim.opt.fileformats = "unix,dos,mac"

-- Neo-tree related
vim.g.neo_tree_remove_legacy_commands = 1 -- Remove legacy commands
