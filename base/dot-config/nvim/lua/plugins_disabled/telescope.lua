return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },

        keys = {
            { "<leader>ff" },
            { "<leader>fa" },
            { "<leader>fg" },
            { "<leader>fb" },
            { "<leader>fh" }
        },
        config = function()
            require('telescope').setup({})
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', function()
                if vim.loop.fs_stat(vim.loop.cwd() .. "/.git") then
                    builtin.git_files()
                else
                    builtin.find_files()
                end
            end)

            vim.keymap.set('n', '<leader>fa', builtin.find_files)
            vim.keymap.set('n', '<leader>fg', builtin.live_grep)
            vim.keymap.set('n', '<leader>fb', builtin.buffers)
            vim.keymap.set('n', '<leader>fh', builtin.help_tags)
        end
    },
    { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },
}
