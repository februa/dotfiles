-- ddu-ff-filter バッファキーマップ
local opts = { buffer = true, silent = true }
vim.keymap.set('i', '<CR>',  function() vim.fn['ddu#ui#do_action']('closeFilterWindow') end, opts)
vim.keymap.set('i', '<C-c>', function() vim.fn['ddu#ui#do_action']('quit') end, opts)
vim.keymap.set('n', '<C-c>', function() vim.fn['ddu#ui#do_action']('quit') end, opts)
