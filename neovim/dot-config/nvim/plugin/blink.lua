vim.pack.add({
    {
        src = 'https://github.com/saghen/blink.cmp',
        version = vim.version.range('1.x'),
    },
    'https://github.com/ribru17/blink-cmp-spell',
    'https://github.com/lukas-reineke/blink-cmp-ripgrep',
    'https://github.com/Kaiser-Yang/blink-cmp-git',
    'https://github.com/erooke/blink-cmp-latex',
    'https://github.com/jmbuhr/cmp-pandoc-references',
})
require('blink.cmp').setup({
    keymap = { preset = 'super-tab' },
    appearance = {
        nerd_font_variant = 'mono'
    },
    completion = {
        list = {
            selection = { preselect = true, auto_insert = false },
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
        },
        ghost_text = { enabled = true },
    },
    cmdline = { enabled = true },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'ripgrep', 'spell', 'git' },
        providers = {
            ripgrep = {
                module = 'blink-cmp-ripgrep',
                name = 'Ripgrep',
            },
            spell = {
                module = 'blink-cmp-spell',
                name = 'Spell',
            },
            git = {
                module = 'blink-cmp-git',
                name = 'Git',
            },
            latex = {
                module = 'blink-cmp-latex',
                name = 'Latex',
            },
            pandoc_references = {
                module = 'cmp-pandoc-references.blink',
                name = 'References',
            },
        },
        per_filetype = {
            quarto = { 'lsp', 'path', 'snippets', 'buffer', 'ripgrep', 'spell', 'git', 'pandoc_references' },
            markdown = { 'lsp', 'path', 'snippets', 'buffer', 'ripgrep', 'spell', 'pandoc_references' },
        },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
})
