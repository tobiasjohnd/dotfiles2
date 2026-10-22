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
    -- No global keymaps: they are set per buffer below, under <localleader>.
})

-- Filetypes that own <localleader> themselves; iron never maps there.
local no_repl = { lean = true }

local function has_repl(ft)
    if no_repl[ft] then return false end
    -- rawget: iron's repl_definition metatable errors on unknown filetypes.
    return rawget(require('iron.config').repl_definition, ft) ~= nil
        or require('iron.fts')[ft] ~= nil
end

local function send_block(move)
    return function()
        local def = rawget(require('iron.config').repl_definition, vim.bo.filetype)
        if not (def and def.block_dividers) then
            vim.notify('iron: no block dividers for ' .. vim.bo.filetype, vim.log.levels.WARN)
            return
        end
        iron.send_code_block(move)
    end
end

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('iron_keymaps', { clear = true }),
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= '' or not has_repl(ev.match) then return end

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, '<localleader>' .. lhs, rhs,
                { buffer = ev.buf, silent = true, desc = 'iron: ' .. desc })
        end

        map('n', 's', function() iron.run_motion('send_motion') end, 'send motion')
        map('n', 'ss', iron.send_line, 'send line')
        map('v', 's', iron.visual_send, 'send selection')
        map('n', 'f', iron.send_file, 'send file')
        map('n', 'b', send_block(false), 'send block')
        map('n', 'n', send_block(true), 'send block and move')
        map('n', 'u', iron.send_until_cursor, 'send until cursor')
        map('n', 'i', '<cmd>IronRepl<cr>', 'toggle repl')
        map('n', 'r', '<cmd>IronRestart<cr>', 'restart repl')
        map('n', '<Tab>', '<cmd>IronFocus<cr>', 'focus repl')
        map('n', '<cr>', function() iron.send(nil, string.char(13)) end, 'send enter')
        map('n', '<space>', function() iron.send(nil, string.char(3)) end, 'interrupt')
        map('n', 'c', function() iron.send(nil, string.char(12)) end, 'clear')
        map('n', 'q', iron.close_repl, 'quit repl')
    end,
})
