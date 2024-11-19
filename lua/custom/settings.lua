--
--
-- Options --
--
--


-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('n', '<S-up>', '<cmd>echo "Use C-b to move!!"<CR>')
vim.keymap.set('n', '<S-down>', '<cmd>echo "Use C-f to move!!"<CR>')

-- prefer vertical split for diffs
vim.opt.diffopt:append('vertical')

-- only save buffers, cwd, and folds for sessions
vim.opt.sessionoptions = 'buffers,curdir,folds'

-- hide ins-completion-menu messages
vim.opt.shortmess:append('c')

-- below folding options cause hangs when opening a file with ft=text, disabling this for now
-- use tree-sitter folding, disable by default
-- vim.wo.foldmethod = 'expr'
-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- vim.opt.foldenable = false

vim.g.have_nerd_font = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.showmatch = true

local function reg_paste(reg)
  return function()
    return vim.split(vim.fn.getreg(reg), '\n')
  end
end

-- use OSC52 for copy
-- use " register for paste as some terminals don't support reading clipboard via OSC52
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = reg_paste('"'),
    ['*'] = reg_paste('"'),
  },
}

-- Disable text wrapping by default, use <leader>tw to toggle
vim.opt.wrap = false

-- Indent settings
-- Keep tabstop to default of 8 https://neovim.io/doc/user/usr_25.html#_tabstop
-- vim.opt.tabstop = 8

-- https://neovim.io/doc/user/options.html#'softtabstop'
-- When 'sts' is negative, the value of 'shiftwidth' is used.
vim.opt.softtabstop = -1

-- My preferred default tab settings, sleuth.vim will change these heuristically
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Don't use smart indent with TS indent queries
vim.opt.smartindent = false

--
--
-- Keybinds --
--
--

-- default opts for keymap
local opts = { noremap = true, silent = true }

-- toggle wrap
vim.keymap.set('n', '<leader>tw', function() vim.o.wrap = not vim.o.wrap end, opts)

-- copy path to buffer
local function copy_buffer_path()
  local buffer_path = vim.fn.expand('%:p')
  -- copy to unnamed (for using p) and *
  vim.fn.setreg('"', buffer_path)
  vim.fn.setreg('*', buffer_path)
end
vim.keymap.set('n', '<leader>cf', copy_buffer_path, opts)

-- User commands

-- p4 commands
require 'custom.configs.p4'

-- other commands
vim.api.nvim_create_user_command('Vrc', 'edit ' .. vim.fn.stdpath('config') .. '/init.lua', {})
vim.api.nvim_create_user_command('Resource', 'source ' .. vim.fn.stdpath('config') .. '/lua/custom/settings.lua', {})
vim.api.nvim_create_user_command('SaveSession', 'mksession! .session.vim', {})
vim.api.nvim_create_user_command('SS', 'SaveSession', {})

-- Opens a diff of the current buffer ran through autopep8 (--agressive)
vim.api.nvim_create_user_command('DiffRuff', function()
  local file_path = vim.fn.expand('%')
  local temp_file = vim.fn.tempname()
  local diff = vim.system({'ruff', 'format', '--diff', file_path}):wait().stdout
  vim.fn.writefile(vim.split(diff, "\n"), temp_file)
  vim.cmd('vert diffp ' .. temp_file)
end, {})

