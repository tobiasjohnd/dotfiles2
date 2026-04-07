vim.pack.add({ 'https://github.com/Vigemus/iron.nvim' })
local iron = require('iron.core')
iron.setup({
    config = {
        repl_definition = {
            python = {
                command = { 'ipython' },
                block_dividers = { '# %%', '#%%' },
                format = require('iron.fts.common').bracketed_paste
            }
        },
        repl_open_cmd = require('iron.view').split.vertical.rightbelow(0.4),
    },
    keymaps = {
        send_motion = '\\',
        visual_send = '\\',
        send_line = '\\\\',
        send_file = '<leader>if',
        send_code_block = '<leader>ib',
        send_code_block_and_move = '<leader>in',
        send_until_cursor = "<space>iu",
        cr = '<leader>i<cr>',
        interrupt = '<leader>i<space>',
        exit = '<leader>iq',
        clear = '<leader>ic',
    },
})
