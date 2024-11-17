-- Wish list: ---
-- set up nvimlsp
    -- lsp zero
-- explore treesitter memes a little more
-- steal from kickstart.nvim
-- debugging?
-- separate our completion and lsp
-- finish telescope conf
-- moar lazyness

--------------------------------------------------------------------------------
-- SETTINGS --------------------------------------------------------------------
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- KEYBINDINGS -----------------------------------------------------------------
--------------------------------------------------------------------------------

-- Quality of Life -------------------------------------------------------------
vim.keymap.set("n", "<leader>x", ":!<Space>")
vim.keymap.set("n", "<leader><leader>", ":w<CR>")
vim.keymap.set("n", "<leader>so", ":source %<CR>")
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set("n", ":" , ";")
vim.keymap.set("n", ";", ":")

-- Move selected line / block of text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor in the center of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- yank and delete to system clipboard
vim.keymap.set({"n", "v"}, "Y", [["+y]])
vim.keymap.set({"n", "v"}, "D", [["+d]])

-- Quickfix and Diagnostics
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- skill issue mediation ------------------------------------------------
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Git ------------------------------------------------------------------
vim.keymap.set("n", "<leader>gs", ":!git status<CR>")
vim.keymap.set("n", "<leader>gc", ":!git commit -m ''<Left><Left>")
vim.keymap.set("n", "<leader>gp", ":!git push<CR>")
vim.keymap.set("n", "<leader>gl", ":!git pull<CR>")
vim.keymap.set("n", "<leader>ga", ":!git add ")
vim.keymap.set("n", "<leader>ga%", ":!git add %<CR>")
vim.keymap.set("n", "<leader>gaa", ":!git add --all<CR>")
vim.keymap.set("n", "<leader>gau", ":!git add -u<CR>")

--------------------------------------------------------------------------------
-- AUTOCOMMANDS ----------------------------------------------------------------
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

--------------------------------------------------------------------------------
-- PLUGINS ---------------------------------------------------------------------
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then

  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    change_detection = {notify = true},
    spec = "plugins",
})
