-- When the cursor rests, ask the attached language servers for extra info about
-- that spot and show it in a popup in the window's bottom-right corner.
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

local function has_float()
    return vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(w)
        return vim.api.nvim_win_get_config(w).relative ~= ''
    end)
end

local function snapshot(buf)
    return { vim.api.nvim_get_current_win(), vim.api.nvim_win_get_cursor(0), vim.b[buf].changedtick }
end

local function show(lines, win)
    local height, width = vim.api.nvim_win_get_height(win), vim.api.nvim_win_get_width(win)
    local _, float = vim.lsp.util.open_floating_preview(lines, 'markdown', vim.tbl_extend('force', float_opts, {
        max_height = math.max(3, math.floor(height / 3)),
        max_width = math.max(20, math.floor(width * 2 / 3)),
    }))
    vim.api.nvim_win_set_config(float, {
        relative = 'win', win = win, anchor = 'SE', row = height, col = width,
    })
end

vim.api.nvim_create_autocmd('CursorHold', {
    group = vim.api.nvim_create_augroup('line_info', {}),
    callback = function(args)
        if has_float() then return end -- don't replace a K hover etc.

        local buf, win = args.buf, vim.api.nvim_get_current_win()
        local before = snapshot(buf)
        local cursor = before[2]
        local ctx = { buf = buf, row = cursor[1] - 1, col = cursor[2] }

        -- One job per (client, source), kept in order so the popup is stable.
        local jobs = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
            for _, source in ipairs(client.config.line_info or {}) do
                table.insert(jobs, { client = client, source = source })
            end
        end
        if #jobs == 0 then return end

        local pending = #jobs
        local function finish()
            pending = pending - 1
            if pending > 0 then return end
            -- Drop the answer if the cursor or text changed while waiting.
            if has_float() or not vim.deep_equal(snapshot(buf), before) then return end

            local lines = {}
            for _, job in ipairs(jobs) do
                if job.lines and #job.lines > 0 then
                    if #lines > 0 then table.insert(lines, '') end
                    vim.list_extend(lines, job.lines)
                end
            end
            if #lines > 0 then show(lines, win) end
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
