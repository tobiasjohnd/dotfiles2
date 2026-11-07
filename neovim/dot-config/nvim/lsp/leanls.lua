---@type vim.lsp.Config
return {
    -- Proof goals at the cursor in the corner popup (lua/line_info).
    line_info = {
        {
            method = '$/lean/plainGoal',
            params = function(buf, cursor)
                return {
                    textDocument = vim.lsp.util.make_text_document_params(buf),
                    -- +1 column, as lean.nvim does: in normal mode the cursor sits
                    -- on a token's first char, which Lean counts as before it.
                    position = {
                        line = cursor[1] - 1,
                        character = vim.str_utfindex(
                            vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1],
                            'utf-16', cursor[2], false) + 1,
                    },
                }
            end,
            render = function(result)
                return vim.split(result.rendered, '\n', { trimempty = true })
            end,
        },
    },
}
