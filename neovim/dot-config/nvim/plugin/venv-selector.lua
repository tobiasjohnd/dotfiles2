vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/linux-cultist/venv-selector.nvim",
})

require("venv-selector").setup({
  options = { picker = "fzf-lua" },
  search = {
    -- default Linux searches don't cover ~/anaconda3
    anaconda3 = {
      command = "$FD '/bin/python$' ~/anaconda3 --full-path --color never --max-depth 4 -E pkgs",
      type = "anaconda",
    },
  },
})

vim.keymap.set("n", ",v", "<cmd>VenvSelect<cr>")
