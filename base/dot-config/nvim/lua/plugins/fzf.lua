return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<cr>" },     -- Has preview by default
            { "<leader>fa", "<cmd>FzfLua find_files" },
            { "<leader>fg", "<cmd>FzfLua live_grep<cr>" }, -- Shows matched lines
            { "<leader>fb", "<cmd>FzfLua buffers<cr>" },   -- Preview buffer content
            { "<leader>fh", "<cmd>FzfLua help_tags<cr>" },
        },
        opts = {}
    }
}
