local Path = require('plenary.path')
local scan = require('plenary.scandir')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

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

local duplicate_file = function(path)
  local ext = vim.fn.fnamemodify(path, ':e')
  local dest = vim.fn.fnamemodify(path, ':r') .. '_copy.' .. ext
  Path.new(path):copy({ override = false, destination = dest })
end

M.setup = function(opts)
  user_opts = opts or {}
  vim.api.nvim_create_user_command('Memo', M.new, {})
  vim.api.nvim_create_user_command('MemoList', M.list, {})
end

M.new = function()
  local now = os.date('%Y%m%d_%H%M%S')
  vim.api.nvim_command('edit ' .. memopath(now .. '.md'))
end

M.rename = function(path)
  vim.ui.input({ prompt = 'New name?\n' }, function(new_name)
    if vim.fn.fnamemodify(new_name, ':e') ~= 'md' then
      new_name = new_name .. '.md'
    end
    new_name = memopath(new_name)
    Path.new(path):rename({ new_name = new_name })
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

M.list = function()
  local entries = M.list_with_title()

  local opts = {}
  pickers
    .new(opts, {
      prompt_title = 'Find Memo (memo.nvim)',
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry[2],
            ordinal = entry[2],
            path = entry[1],
          }
        end,
      }),
      sorter = conf.file_sorter(opts),
      previewer = conf.file_previewer(opts),
      attach_mappings = function(bufnr, map)
        map('i', '<C-d>', function(_)
          local entry = action_state.get_selected_entry()
          local path = entry.value[1]
          if M.remove(path) then
            print('Deleted ' .. path)
          end
          actions.close(bufnr)
        end)
        map('i', '<C-r>', function(_)
          local entry = action_state.get_selected_entry()
          local path = entry.value[1]
          M.rename(path)
          actions.close(bufnr)
        end)
        map('i', '<C-y>', function(_)
          local entry = action_state.get_selected_entry()
          local path = entry.value[1]
          duplicate_file(path)
          actions.close(bufnr)
        end)
        return true
      end,
    })
    :find()
end

return M
