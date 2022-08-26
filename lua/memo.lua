local Path = require('plenary.path')
local scan = require('plenary.scandir')
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

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
  vim.api.nvim_create_user_command('MemoList', M.list, {})
end

M.new = function()
  local now = os.date('%Y%m%d_%H%M%S')
  vim.api.nvim_command('edit ' .. memopath(now .. '.md'))
end

M.list = function()
  local memo_dir = vim.fn.fnamemodify(get_opt('memo_dir'), ':p:h')
  local memolist = scan.scan_dir(memo_dir, { depth = 1 })

  local entries = {}
  for _, path in pairs(memolist) do
    local head1 = Path.new(path):head(1)
    local filename = vim.fn.fnamemodify(path, ':t')
    table.insert(entries, { path, filename .. ' : ' .. head1})
  end

  local opts = {}
  pickers.new(opts, {
    prompt_title = 'Find Memo (memo.nvim)',
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[2],
          ordinal = entry[2],
          path = entry[1]
        }
      end
    },
    sorter = conf.file_sorter(opts),
    previewer = conf.file_previewer(opts),
  }):find()
end

return M
