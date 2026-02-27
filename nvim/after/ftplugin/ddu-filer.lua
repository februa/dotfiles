-- ddu-filer バッファキーマップ
local opts = { buffer = true, silent = true }
vim.keymap.set('n', '<CR>',    function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'open' }) end, opts)
vim.keymap.set('n', 'l',       function() vim.fn['ddu#ui#do_action']('expandItem', { mode = 'toggle' }) end, opts)
vim.keymap.set('n', 'h',       function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'narrow', params = { path = '..' }}) end, opts)
vim.keymap.set('n', 'q',       function() vim.fn['ddu#ui#do_action']('quit') end, opts)
vim.keymap.set('n', '<C-c>',   function() vim.fn['ddu#ui#do_action']('quit') end, opts)
vim.keymap.set('n', '<Space>', function() vim.fn['ddu#ui#do_action']('toggleSelectItem') end, opts)
vim.keymap.set('n', 'c',       function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'copy' }) end, opts)
vim.keymap.set('n', 'p',       function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'paste' }) end, opts)
vim.keymap.set('n', 'd',       function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'delete' }) end, opts)
vim.keymap.set('n', 'r',       function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'rename' }) end, opts)
vim.keymap.set('n', 't',       function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'newFile' }) end, opts)
vim.keymap.set('n', 'mk',      function() vim.fn['ddu#ui#do_action']('itemAction', { name = 'newDirectory' }) end, opts)
