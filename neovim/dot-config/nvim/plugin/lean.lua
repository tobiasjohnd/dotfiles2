-- lean.nvim starts the Lean server (lake serve) itself, so it is not in lua/lsp.lua.
-- Its keymaps are buffer-local under <localleader> (\), e.g. \i toggles the infoview.
vim.g.lean_config = { mappings = true }
vim.pack.add({ 'https://github.com/Julian/lean.nvim' })
