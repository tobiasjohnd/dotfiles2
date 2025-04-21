vim.g.lazydev_enabled = true
vim.g.mapleader=' '

vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.termguicolors=true

vim.opt.showmode=false
vim.opt.cmdheight=1

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.wrap = false

vim.opt.mouse='a'
vim.opt.updatetime=100

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.scrolloff = 5
