-- Keymaps are buffer-local under <localleader> (\), e.g. \i toggles the infoview.
vim.g.lean_config = {
    mappings = true,
    -- The server ('leanls') is enabled in lua/lsp.lua with the others; its config is
    -- lean.nvim's lsp/leanls.lua plus our lsp/leanls.lua.
    lsp = { enable = false },
    -- Goals show in the corner popup (lua/line_info); \i opens the full infoview.
    infoview = { autoopen = false },
}
vim.pack.add({ 'https://github.com/Julian/lean.nvim' })
