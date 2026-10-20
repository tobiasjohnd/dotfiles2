---@brief
--
---
--- https://github.com/astral-sh/ruff
---
--- `ruff`, a python linter and formatter. Runs alongside basedpyright (lsp/python.lua).

---@type vim.lsp.Config
return {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    settings = {},
    on_attach = function(client)
        -- basedpyright gives much richer hover info, so don't show ruff's as well.
        client.server_capabilities.hoverProvider = false
    end,
}
