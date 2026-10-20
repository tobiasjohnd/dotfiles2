local function on_lsp_attach(client, buf)
    --[[
    if client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end
    ]]

    if client:supports_method('textDocument/formatting') then
        vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = buf,
            callback = function()
                vim.lsp.buf.format({ bufnr = buf, id = client.id })
            end,
        })
    end

    -- Inlay hints are not drawn inline; lua/line_info.lua shows them in a popup.

    if client:supports_method('textDocument/documentHighlight') then
        local autocmd = vim.api.nvim_create_autocmd
        local augroup = vim.api.nvim_create_augroup('lsp_highlight', { clear = false })

        vim.api.nvim_clear_autocmds({ buffer = buf, group = augroup })

        autocmd({ 'CursorHold' }, {
            group = augroup,
            buffer = buf,
            callback = vim.lsp.buf.document_highlight,
        })

        autocmd({ 'CursorMoved' }, {
            group = augroup,
            buffer = buf,
            callback = vim.lsp.buf.clear_references,
        })
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
            on_lsp_attach(client, args.buf)
        end
    end
})

vim.lsp.enable({ 'lua', 'python', 'python_ruff', 'go', 'c' })
-- jdtls not enabled here nvim-jdtls sorts itself out.
