vim.pack.add({
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/jiaoshijie/undotree',
})
require('undotree').setup({})
vim.keymap.set('n', '<leader>u', '<cmd>lua require("undotree").toggle()<cr>')
