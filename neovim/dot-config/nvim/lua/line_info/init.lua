-- When the cursor rests, ask the attached language servers for extra info about
-- that spot and show it in a popup in the window's bottom-right corner. This
-- happens in normal mode, and in insert mode for sources that set `insert`.
--
-- What to ask for comes from "sources" that each server opts into from its
-- lsp/<name>.lua file:
--
--   line_info = { source, ... }
--
--   ---@class line_info.Source
--   ---@field method string                              LSP request to send
--   ---@field params fun(buf: integer, cursor: integer[]): table
--   ---@field render fun(result: any, ctx: line_info.Ctx): string[]|nil  markdown lines
--   ---@field insert? boolean    also ask in insert mode; the popup then stays up while typing
--
--   ---@class line_info.Ctx
--   ---@field buf integer
--   ---@field row integer     0-based
--   ---@field col integer     0-based byte column
--   ---@field client vim.lsp.Client

local float_opts = {
    border = 'rounded',
    focus = false,
}

-- The popup we last opened: { win = its window, anchor = the window it sits in, lines = its text }.
local popup

-- Another LSP float on this buffer (a K hover etc.), which ours would replace.
local function other_float(buf)
    local float = vim.b[buf].lsp_floating_preview
    return float ~= nil and vim.api.nvim_win_is_valid(float) and not (popup and popup.win == float)
end

local function snapshot(buf)
    return {
        vim.api.nvim_get_current_win(), vim.api.nvim_win_get_cursor(0),
        vim.b[buf].changedtick, vim.api.nvim_get_mode().mode,
    }
end

-- Show `lines` in the corner of `win` in place of our previous popup; no lines
-- just closes it. A `sticky` popup stays up while typing in insert mode.
local function show(lines, win, sticky)
    local open = popup ~= nil and vim.api.nvim_win_is_valid(popup.win)
    if open and popup.anchor == win and vim.deep_equal(popup.lines, lines) then return end
    if #lines == 0 then
        if open then vim.api.nvim_win_close(popup.win, true) end
        return
    end

    local height, width = vim.api.nvim_win_get_height(win), vim.api.nvim_win_get_width(win)
    local _, float = vim.lsp.util.open_floating_preview(lines, 'markdown', vim.tbl_extend('force', float_opts, {
        max_height = math.max(3, math.floor(height / 3)),
        max_width = math.max(20, math.floor(width * 2 / 3)),
        close_events = sticky and { 'CursorMoved' } or nil,
    }))
    vim.api.nvim_win_set_config(float, {
        relative = 'win', win = win, anchor = 'SE', row = height, col = width,
    })
    popup = { win = float, anchor = win, lines = lines }
end

vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = vim.api.nvim_create_augroup('line_info', {}),
    callback = function(args)
        local buf, win = args.buf, vim.api.nvim_get_current_win()
        if other_float(buf) then return end -- don't replace a K hover etc.

        local insert = args.event == 'CursorHoldI'
        local before = snapshot(buf)
        local cursor = before[2]
        local ctx = { buf = buf, row = cursor[1] - 1, col = cursor[2] }

        -- One job per (client, source), kept in order so the popup is stable.
        -- In insert mode only the sources that asked for it run.
        local jobs = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
            for _, source in ipairs(client.config.line_info or {}) do
                if source.insert or not insert then
                    table.insert(jobs, { client = client, source = source })
                end
            end
        end
        if #jobs == 0 then return end

        local pending = #jobs
        local function finish()
            pending = pending - 1
            if pending > 0 then return end
            -- Drop the answer if the cursor or text changed while waiting.
            if other_float(buf) or not vim.deep_equal(snapshot(buf), before) then return end

            local lines, sticky = {}, false
            for _, job in ipairs(jobs) do
                if job.lines and #job.lines > 0 then
                    if #lines > 0 then table.insert(lines, '') end
                    vim.list_extend(lines, job.lines)
                    sticky = sticky or job.source.insert
                end
            end
            show(lines, win, sticky)
        end

        for _, job in ipairs(jobs) do
            local ok, params = pcall(job.source.params, buf, cursor)
            local sent = ok and job.client:request(job.source.method, params, function(err, result)
                if not err and result ~= nil then
                    local jctx = vim.tbl_extend('force', ctx, { client = job.client })
                    local rok, lines = pcall(job.source.render, result, jctx)
                    if rok then job.lines = lines end
                end
                finish()
            end, buf)
            if not sent then finish() end
        end
    end,
})
