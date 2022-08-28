# memo.nvim

`memo.nvim` is a very simple memo plugin for neovim.

This plugin provides two lua functions (and vim commands).

* `require('memo').new` (lua) or `:Memo` (vim)
  * Open a markdown file whose name is like timestmap.
* `require('memo').list` (lua) or `:MemoList` (vim)
  * Find memo using fuzzy finder and open it.
  * `<C-d>` to delete memo under the cursor
  * `<C-r>` to rename memo under the cursor
  * `<C-c>` to duplicate memo under the cursor

## Requirements

* [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Setup
```lua
-- with Packer
use {
 'utouto97/memo.nvim',
  requires = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require('memo').setup(
      memo_dir = '~/.memo'
    )
  end
}
```

If you want to change `memo_dir` where your memo are placed,
you can call `require('memo').setup()` and change `memo_dir` in its options.

**optional**  
Keymaps like this would help you to use this plugin.

```lua
vim.keymap.set('n', '<Leader>mn', '<cmd>Memo<cr>')
vim.keymap.set('n', '<Leader>mm', '<cmd>MemoList<cr>')
```
