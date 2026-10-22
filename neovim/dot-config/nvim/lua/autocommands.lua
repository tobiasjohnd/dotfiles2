vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
  end,
})

-- Autosave after every edit. Formatting is held back so code doesn't move
-- while you work: it runs on leaving insert mode, on a manual :w (see
-- lsp.lua), or once the buffer has had no edits for FORMAT_DELAY_MS.
local FORMAT_DELAY_MS = 10000
local group = vim.api.nvim_create_augroup('autosave', { clear = true })
local timers = {} -- buf -> timer; present while a format is pending

local function savable(buf)
  local bo = vim.bo[buf]
  return bo.buftype == '' and bo.modifiable and not bo.readonly
    and vim.api.nvim_buf_get_name(buf) ~= ''
end

-- Write the buffer, skipping the format-on-save hook in lsp.lua.
local function save(buf)
  if not vim.bo[buf].modified then
    return
  end
  vim.b[buf].autosaving = true
  vim.api.nvim_buf_call(buf, function()
    vim.cmd('silent! lockmarks update')
  end)
  vim.b[buf].autosaving = nil
end

local function cancel_format(buf)
  local t = timers[buf]
  if t then
    t:stop()
    t:close()
    timers[buf] = nil
  end
end

local function format_and_save(buf)
  cancel_format(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if #vim.lsp.get_clients({ bufnr = buf, method = 'textDocument/formatting' }) > 0 then
    vim.lsp.buf.format({ bufnr = buf })
  end
  save(buf)
end

local function schedule_format(buf)
  cancel_format(buf)
  local t = vim.uv.new_timer()
  timers[buf] = t
  t:start(FORMAT_DELAY_MS, 0, vim.schedule_wrap(function()
    if timers[buf] ~= t then
      return
    end
    -- Only format from plain normal mode, never mid-command or in insert.
    local m = vim.api.nvim_get_mode()
    if m.mode ~= 'n' or m.blocking then
      schedule_format(buf)
    else
      format_and_save(buf)
    end
  end))
end

vim.api.nvim_create_autocmd('TextChanged', {
  desc = 'Autosave after normal-mode edits; format later',
  group = group,
  callback = function(args)
    if savable(args.buf) and vim.bo[args.buf].modified then
      save(args.buf)
      schedule_format(args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd('TextChangedI', {
  desc = 'Push back pending format while typing',
  group = group,
  callback = function(args)
    if savable(args.buf) then
      schedule_format(args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  desc = 'Format and save on leaving insert mode',
  group = group,
  callback = function(args)
    if savable(args.buf) and (timers[args.buf] or vim.bo[args.buf].modified) then
      format_and_save(args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd('BufWipeout', {
  desc = 'Drop pending format timer',
  group = group,
  callback = function(args)
    cancel_format(args.buf)
  end,
})
