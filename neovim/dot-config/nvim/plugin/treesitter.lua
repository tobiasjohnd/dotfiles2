vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
        if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
        vim.cmd('TSUpdate')
    end
end })

vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })

require('nvim-treesitter').install({ 'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline', 'python' })
vim.treesitter.language.register('markdown', 'quarto')

vim.api.nvim_create_autocmd('FileType', {
    callback = function(ev)
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        local lang = vim.treesitter.language.get_lang(ev.match)
        if lang then
            require('nvim-treesitter').install({ lang })
        end
    end,
})
