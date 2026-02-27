-- zk ノート操作（markdown 限定）
--   szl: 現在のノートのリンク先一覧
--   szb: 現在のノートへのバックリンク一覧
vim.keymap.set('n', 'szl', function() require('plugins.zk').list_links() end, { buffer = true, silent = true })
vim.keymap.set('n', 'szb', function() require('plugins.zk').list_backlinks() end, { buffer = true, silent = true })
