-- Side panel: Claude Code, REPLs and plain terminals share one pair of
-- bindings, which act on whichever terminal buffer was opened most recently.
--   <C-;>      show/hide the panel
--   <C-,>      swap between the panel and the code
--   <leader>a  show/hide Claude Code, starting it on first use
-- Hiding a panel keeps its job running.

local opened = {} -- terminal buffers, most recently opened last
local claude      -- Claude Code's terminal buffer

local function mark_opened(buf)
    for i, b in ipairs(opened) do
        if b == buf then
            table.remove(opened, i)
            break
        end
    end
    table.insert(opened, buf)
end

vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('panel', { clear = true }),
    callback = function(ev)
        local win = vim.fn.bufwinid(ev.buf)
        -- Floating terminals (fzf pickers) are not panels.
        if vim.bo[ev.buf].buftype == 'terminal' and win ~= -1
            and vim.api.nvim_win_get_config(win).relative == '' then
            mark_opened(ev.buf)
        end
    end,
})

-- The most recently opened terminal buffer that still exists.
local function latest()
    while #opened > 0 do
        if vim.api.nvim_buf_is_valid(opened[#opened]) then
            return opened[#opened]
        end
        table.remove(opened)
    end
    vim.notify('No terminal buffer to show', vim.log.levels.WARN)
end

local function open_split(cmd)
    vim.cmd('botright vertical ' .. cmd)
    vim.api.nvim_win_set_width(0, math.floor(vim.o.columns * 0.4))
end

-- If the cursor is in the panel, go back to the window it came from.
local function leave(win)
    if vim.api.nvim_get_current_win() == win then
        vim.cmd.stopinsert()
        vim.cmd.wincmd('p')
    end
end

local function toggle()
    local buf = latest()
    if not buf then return end
    local win = vim.fn.bufwinid(buf)
    if win == -1 then
        open_split('sbuffer ' .. buf)
        vim.cmd.startinsert()
        return
    end
    leave(win)
    -- The last window cannot be closed; show the previous buffer in it instead.
    if not pcall(vim.api.nvim_win_close, win, false) then
        pcall(vim.cmd.buffer, '#')
    end
end

local function swap()
    local buf = latest()
    if not buf then return end
    local win = vim.fn.bufwinid(buf)
    if win == vim.api.nvim_get_current_win() then
        leave(win)
        return
    elseif win == -1 then
        open_split('sbuffer ' .. buf)
    else
        vim.api.nvim_set_current_win(win)
    end
    vim.cmd.startinsert()
end

local function toggle_claude()
    if claude and vim.api.nvim_buf_is_valid(claude) then
        mark_opened(claude)
        toggle()
        return
    end
    if vim.fn.executable('claude') == 0 then
        vim.notify('claude is not on PATH', vim.log.levels.ERROR)
        return
    end
    open_split('new')
    local buf = vim.api.nvim_get_current_buf()
    claude = buf
    vim.fn.jobstart({ 'claude' }, {
        term = true,
        on_exit = function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end,
    })
    vim.cmd.startinsert()
end

vim.keymap.set({ 'n', 't' }, '<C-;>', toggle, { desc = 'Panel: show/hide' })
vim.keymap.set({ 'n', 't' }, '<C-,>', swap, { desc = 'Panel: swap with code' })
vim.keymap.set('n', '<leader>a', toggle_claude, { desc = 'Claude Code: show/hide' })
