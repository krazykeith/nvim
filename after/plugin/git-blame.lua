local blame = require('gitblame')
local blame2 = require('blame')

vim.keymap.set('n', '<leader>b', '<cmd>GitBlameToggle<cr> <Bar> <cmd>ToggleBlame virtual<cr>')
vim.keymap.set('n', '<leader>o', '<cmd>GitBlameOpenCommitURL<cr>')
blame.setup({})
