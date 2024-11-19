return {
    {"CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        dependencies = {
            { "github/copilot.vim" }, -- or github/copilot.vim
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            debug = true,
            model= "claude-3.5-sonnet",
            auto_intert_mode = true,
            insert_at_end = true,

            -- See Configuration section for rest
        },
        -- See Commands section for default commands if you want to lazy load on them
    },
    {"brenoprata10/nvim-highlight-colors", -- nice highlighting for css colours
        opts = {
            render = 'background',
            --render = 'foreground',
            --render = 'virtual',
            virtual_symbol_position = 'eow',--'eol', 'inline'
            virtual_symbol_prefix = '',
            virtual_symbol_suffix = ' ',
        }
    },
    {"editorconfig/editorconfig-vim"},
    { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },

    {"jiaoshijie/undotree",
        dependencies = "nvim-lua/plenary.nvim",
        config = true,
        keys = { -- load the plugin only when using it's keybinding:
            { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
        },
    },

    { "j-hui/fidget.nvim" },
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end,

    { "williamboman/mason.nvim", opts = {} },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "lua_ls",
                "clangd", -- requires python
                "cmake", -- requires unzip
                "bashls", -- requires node
                "pyright",
            },
            handlers = {
                function(server)
                    require("lspconfig")[server].setup({})
                end
            },
        },
        dependencies = {
            "neovim/nvim-lspconfig",
        }
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
                sync_install = false,
                auto_install = true,
                ignore_install = {},
                modules = {},

                indent = {
                    enable = true
                },

                highlight = {
                    enable = true,

                    additional_vim_regex_highlighting = false,
                },
            })
            vim.filetype.add({
                pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
            })
        end
    },

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
            vim.keymap.set('n', ',leader>fh', builtin.help_tags)
        end
    },

    {
        "rshkarin/mason-nvim-lint",
        opts = {
            ensure_installed = {},
            automatic_installation = true,
            quiet_mode = false,
        },
    },
    {
        "mfussenegger/nvim-lint",
        config = function ()
            require('lint').linters_by_ft = {
                python = {'ruff', 'mypy'},
            }
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end
    }
}
