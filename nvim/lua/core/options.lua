local opt = vim.opt
local g = vim.g

-- Leader keys
g.mapleader = " "
g.maplocalleader = "\\"

-- Performance critical
opt.updatetime = 500
opt.timeoutlen = 200
opt.ttimeoutlen = 0
opt.lazyredraw = true
opt.ttyfast = true

-- Memory and CPU
opt.maxmempattern = 20000
opt.synmaxcol = 300
opt.scrollback = 10000

-- File handling
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileencodings = "utf-8,ucs-bom,gb18030,gbk,gb2312,cp936"
opt.autoread = true
opt.backup = false
opt.writeany = true
opt.writebackup = false
opt.swapfile = true
opt.undofile = false
--opt.undodir = vim.fn.expand("~/.config/nvim/undo")

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes:1"
opt.colorcolumn = "120"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 15
opt.cursorline = true

-- Editing
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true
opt.showmatch = true
opt.matchtime = 2

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
opt.pumblend = 0

-- Splits
opt.splitbelow = true
opt.splitright = true
opt.clipboard = "unnamedplus"

local disabled_built_ins = {
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end
