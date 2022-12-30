# memo.nvim

`memo.nvim` is a very simple memo plugin for neovim.

This plugin provides
* `require('memo').new` (lua) or `:Memo` (vim)
  * Open a markdown file whose name is like timestmap.
* `Telescope memo`
  * Find memo using fuzzy finder (Telescope) and open it.
  * `<C-a>` to create new memo
  * `<C-d>` to delete memo under the cursor
  * `<C-r>` to rename memo under the cursor
  * `<C-c>` to duplicate memo under the cursor
* other lua functions like `copy`, `remove` and `rename`

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
vim.keymap.set('n', '<Leader>mm', '<cmd>Telescope memo<cr>')
```
