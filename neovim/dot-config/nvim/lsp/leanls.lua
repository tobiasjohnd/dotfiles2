---@type vim.lsp.Config
return {
    -- Proof goals at the cursor in the corner popup (lua/line_info), kept up
    -- to date while typing too.
    line_info = {
        {
            method = '$/lean/plainGoal',
            insert = true,
            params = function(buf, cursor)
                -- +1 column, as lean.nvim does: in normal mode the cursor sits
                -- on a token's first char, which Lean counts as before it. In
                -- insert mode the cursor is already between chars.
                local shift = vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' and 0 or 1
                return {
                    textDocument = vim.lsp.util.make_text_document_params(buf),
                    position = {
                        line = cursor[1] - 1,
                        character = vim.str_utfindex(
                            vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1],
                            'utf-16', cursor[2], false) + shift,
                    },
                }
            end,
            render = function(result)
                return vim.split(result.rendered, '\n', { trimempty = true })
            end,
        },
    },
}
