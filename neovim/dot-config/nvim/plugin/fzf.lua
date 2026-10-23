vim.pack.add({ 'https://github.com/ibhagwan/fzf-lua' })
-- Route vim.ui.select (e.g. the built-in gra code action menu) through fzf-lua.
require('fzf-lua').register_ui_select()
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>')
vim.keymap.set('n', '<leader>fa', '<cmd>FzfLua find_files')
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>')
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<cr>')
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua help_tags<cr>')
vim.keymap.set({ 'n', 'x' }, '<leader>ca', '<cmd>FzfLua lsp_code_actions<cr>')
