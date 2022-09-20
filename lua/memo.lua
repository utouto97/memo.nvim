local Path = require('plenary.path')
local scan = require('plenary.scandir')

local M = {}

local default_opts = {
  memo_dir = '~/.memo',
}
local user_opts = {}
local get_opt = function(key)
  return user_opts[key] or default_opts[key]
end

local memopath = function(filename)
  local memo_dir = vim.fn.fnamemodify(get_opt('memo_dir'), ':p:h')
  return memo_dir .. '/' .. filename
end

M.setup = function(opts)
  user_opts = opts or {}
  vim.api.nvim_create_user_command('Memo', M.new, {})
end

M.new = function()
  local now = os.date('%Y%m%d_%H%M%S')
  vim.api.nvim_command('edit ' .. memopath(now .. '.md'))
end

M.copy = function(path)
  local ext = vim.fn.fnamemodify(path, ':e')
  local dest = vim.fn.fnamemodify(path, ':r') .. '_copy.' .. ext
  Path.new(path):copy({ override = false, destination = dest })
end

M.rename = function(path)
  vim.ui.input({ prompt = 'New name?\n' }, function(dest)
    if vim.fn.fnamemodify(dest, ':e') ~= 'md' then
      dest = dest .. '.md'
    end
    dest = memopath(dest)
    Path.new(path):rename({ new_name = dest })
  end)
end

M.remove = function(path)
  if vim.fn.confirm('Delete?: ' .. path, '&Yes\n&No', 1) ~= 1 then
    return false
  end

  if vim.fn.confirm('Really?: ' .. path, '&Yes\n&No', 1) ~= 1 then
    return false
  end

  Path.new(path):rm()
  return true
end

M.list_with_title = function()
  local memo_dir = vim.fn.fnamemodify(get_opt('memo_dir'), ':p:h')
  local memolist = scan.scan_dir(memo_dir, { depth = 1 })

  local entries = {}
  for _, path in pairs(memolist) do
    local head1 = Path.new(path):head(1)
    local filename = vim.fn.fnamemodify(path, ':t')
    table.insert(entries, { path, filename .. ' : ' .. head1 })
  end

  return entries
end

return M
