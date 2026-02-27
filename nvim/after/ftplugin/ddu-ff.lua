-- ddu-ff バッファキーマップ
local opts = { buffer = true, silent = true }
vim.keymap.set('n', '<CR>',  function() vim.fn['ddu#ui#do_action']('itemAction') end, opts)
vim.keymap.set('n', '<Space>', function() vim.fn['ddu#ui#do_action']('toggleSelectItem') end, opts)
vim.keymap.set('n', 'i',     function() vim.fn['ddu#ui#do_action']('openFilterWindow') end, opts)
vim.keymap.set('n', 'a',     function() vim.fn['ddu#ui#do_action']('openFilterWindow') end, opts)
vim.keymap.set('n', 'p',     function() vim.fn['ddu#ui#do_action']('preview') end, opts)
vim.keymap.set('n', 'q',     function() vim.fn['ddu#ui#do_action']('quit') end, opts)
vim.keymap.set('n', '<C-c>', function() vim.fn['ddu#ui#do_action']('quit') end, opts)
vim.keymap.set('n', '<C-j>', 'j', opts)
vim.keymap.set('n', '<C-k>', 'k', opts)
