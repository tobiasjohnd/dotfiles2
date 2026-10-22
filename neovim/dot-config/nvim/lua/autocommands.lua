vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})


vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
  desc = 'Autosave after edits in normal mode',
  group = vim.api.nvim_create_augroup('autosave', { clear = true }),
  callback = function(args)
    local bo = vim.bo[args.buf]
    if bo.buftype ~= '' or not bo.modifiable or bo.readonly or not bo.modified then
      return
    end
    if vim.api.nvim_buf_get_name(args.buf) == '' then
      return
    end
    vim.api.nvim_buf_call(args.buf, function()
      vim.cmd('silent! lockmarks update')
    end)
  end,
})
