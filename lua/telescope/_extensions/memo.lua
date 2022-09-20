local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local memo = require('memo')

local telescope_memo = function()
  local entries = memo.list_with_title()
  local opts = {}
  return pickers
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
          if memo.remove(path) then
            print('Deleted ' .. path)
          end
          actions.close(bufnr)
        end)
        map('i', '<C-r>', function(_)
          local entry = action_state.get_selected_entry()
          local path = entry.value[1]
          memo.rename(path)
          actions.close(bufnr)
        end)
        map('i', '<C-y>', function(_)
          local entry = action_state.get_selected_entry()
          local path = entry.value[1]
          memo.copy(path)
          actions.close(bufnr)
        end)
        return true
      end,
    })
    :find()
end

return require('telescope').register_extension({
  exports = {
    memo = telescope_memo,
  },
})
