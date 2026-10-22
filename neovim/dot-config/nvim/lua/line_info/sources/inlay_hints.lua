-- line_info source: the current line with its LSP inlay hints written in,
-- e.g. `x: int = f()`. Any server that sends inlay hints can opt in.

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

---@type line_info.Source
return {
    method = 'textDocument/inlayHint',
    params = function(buf, cursor)
        local row = cursor[1] - 1
        return {
            textDocument = vim.lsp.util.make_text_document_params(buf),
            range = { start = { line = row, character = 0 }, ['end'] = { line = row + 1, character = 0 } },
        }
    end,
    render = function(result, ctx)
        local hints = vim.tbl_filter(function(h) return h.position.line == ctx.row end, result)
        if #hints == 0 then return nil end
        local text = vim.api.nvim_buf_get_lines(ctx.buf, ctx.row, ctx.row + 1, false)[1]
        return { '```' .. vim.bo[ctx.buf].filetype, line_with_hints(text, hints), '```' }
    end,
}
