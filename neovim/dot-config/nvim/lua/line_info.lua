-- When the cursor rests on a line, show its LSP inlay hints in a popup in the
-- window's bottom-right corner, instead of drawing them inside the code.

local function has_float()
    return vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(w)
        return vim.api.nvim_win_get_config(w).relative ~= ''
    end)
end

local function snapshot(buf)
    return { vim.api.nvim_get_current_win(), vim.api.nvim_win_get_cursor(0), vim.b[buf].changedtick }
end

-- The code line with each hint inserted where the LSP placed it.
local function line_with_hints(text, hints)
    -- Right-to-left so earlier positions stay valid.
    table.sort(hints, function(a, b) return a.position.character > b.position.character end)
    for _, h in ipairs(hints) do
        local label = type(h.label) == 'string' and h.label
            or vim.iter(h.label):map(function(part) return part.value end):join('')
        label = (h.paddingLeft and ' ' or '') .. label .. (h.paddingRight and ' ' or '')
        local col = vim.str_byteindex(text, 'utf-16', h.position.character, false)
        text = text:sub(1, col) .. label .. text:sub(col + 1)
    end
    return vim.trim(text)
end

vim.api.nvim_create_autocmd('CursorHold', {
    group = vim.api.nvim_create_augroup('line_info', {}),
    callback = function(args)
        if has_float() then return end -- don't replace a K hover etc.

        local buf, win = args.buf, vim.api.nvim_get_current_win()
        local before = snapshot(buf)
        local row = before[2][1] - 1
        local params = {
            textDocument = vim.lsp.util.make_text_document_params(buf),
            range = { start = { line = row, character = 0 }, ['end'] = { line = row + 1, character = 0 } },
        }

        vim.lsp.buf_request_all(buf, 'textDocument/inlayHint', params, function(results)
            -- Drop the answer if the cursor or text changed while waiting.
            if has_float() or not vim.deep_equal(snapshot(buf), before) then return end

            local hints = {}
            for _, res in pairs(results) do
                vim.list_extend(hints, vim.tbl_filter(function(h) return h.position.line == row end, res.result or {}))
            end
            if #hints == 0 then return end

            local text = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
            local _, float = vim.lsp.util.open_floating_preview(
                { '```' .. vim.bo[buf].filetype, line_with_hints(text, hints), '```' },
                'markdown', { border = 'rounded', focus = false })
            vim.api.nvim_win_set_config(float, {
                relative = 'win', win = win, anchor = 'SE',
                row = vim.api.nvim_win_get_height(win), col = vim.api.nvim_win_get_width(win),
            })
        end)
    end,
})
