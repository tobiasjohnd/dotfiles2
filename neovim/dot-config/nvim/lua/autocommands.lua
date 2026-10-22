vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
  end,
})

-- Autosave after every edit. Normal-mode edits save without formatting so
-- code doesn't move while you work; leaving insert mode or a manual :w
-- formats as usual (see lsp.lua).
local function autosave(buf, format)
  local bo = vim.bo[buf]
  if bo.buftype ~= '' or not bo.modifiable or bo.readonly or not bo.modified then
    return
  end
  if vim.api.nvim_buf_get_name(buf) == '' then
    return
  end
  vim.b[buf].autosaving = not format or nil
  vim.api.nvim_buf_call(buf, function()
    vim.cmd('silent! lockmarks update')
  end)
  vim.b[buf].autosaving = nil
end

local group = vim.api.nvim_create_augroup('autosave', { clear = true })

vim.api.nvim_create_autocmd('TextChanged', {
  desc = 'Autosave normal-mode edits without formatting',
  group = group,
  nested = true, -- let BufWritePre/BufWritePost hooks run
  callback = function(args)
    autosave(args.buf, false)
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  desc = 'Format and save on leaving insert mode',
  group = group,
  nested = true, -- let BufWritePre/BufWritePost hooks run
  callback = function(args)
    autosave(args.buf, true)
  end,
})
