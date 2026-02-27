-- Neovim エントリポイント
-- vim.g.load_extensions = false で基本設定のみ起動（プラグインなし）
vim.g.load_extensions = true
vim.g.debug_mode = false

vim.opt.verbose = 0
vim.api.nvim_create_augroup("MyAutoCmd", { clear = true })

-- 基本設定（常に読み込み）
require('core.options')
require('core.keymaps')
require('core.autocmds')
require('core.project')

if vim.g.load_extensions then
  -- 拡張機能: dpp.vim によるプラグイン管理
  dofile(vim.fn.stdpath('config') .. '/dpp/init.lua')
else
  -- フォールバック UI（自作ステータスライン + vim カラースキーム）
  require('core.ui')
end
