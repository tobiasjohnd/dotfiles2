vim.pack.add({ 'https://github.com/maxmx03/solarized.nvim' })
vim.o.termguicolors = true
vim.o.background = 'light'
require('solarized').setup({})
vim.cmd.colorscheme('solarized')
