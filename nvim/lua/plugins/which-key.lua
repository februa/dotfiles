local wk = require('which-key')

wk.setup({
  preset = 'helix',
  delay = 300,
  icons = {
    mappings = false,
  },
})

wk.add({
  -- s prefix: ddu + window + zk
  { 's',   group = 'ddu/search' },
  { 'sn',  desc = 'ファイラー (cwd)' },
  { 'sN',  desc = 'ファイル検索 (buf dir)' },
  { 's;',  desc = 'バッファ一覧' },
  { 'sm',  desc = 'バッファ + MRU' },
  { 's/',  desc = '行検索' },
  { 'sg',  desc = 'grep (ripgrep)' },
  { 'sh',  desc = '← ウィンドウ移動' },
  { 'sj',  desc = '↓ ウィンドウ移動' },
  { 'sk',  desc = '↑ ウィンドウ移動' },
  { 'sl',  desc = '→ ウィンドウ移動' },
  { 'sa',  group = 'AI/avante', mode = { 'n', 'x' } },
  { 'saa', desc = 'AI に質問', mode = { 'n', 'x' } },
  { 'san', desc = '新しい会話' },
  { 'sat', desc = 'サイドバー切替' },
  { 'sae', desc = '選択範囲を編集', mode = { 'n', 'x' } },
  { 'sar', desc = 'AI応答を再生成' },
  { 'sah', desc = '会話履歴' },
  { 'sam', desc = 'モデル切替' },
  { 'sz',  group = 'zk/ノート' },
  { 'szn', desc = '新規ノート' },
  { 'szo', desc = 'ノート一覧' },
  { 'szt', desc = 'タグフィルタ' },
  { 'szf', desc = 'ノート検索' },

  -- f prefix: LSP navigation
  { 'f',   group = 'LSP' },
  { 'fd',  desc = '定義へ移動' },
  { 'fD',  desc = '宣言へ移動' },
  { 'fi',  desc = '実装へ移動' },
  { 'fr',  desc = '参照一覧' },
  { 'ft',  desc = '型定義へ移動' },

  -- g prefix: Git
  { 'g',   group = 'Git' },
  { 'gs',  desc = 'git status' },
  { 'gd',  desc = 'git diff split' },
  { 'gb',  desc = 'git blame' },
  { 'gl',  desc = 'git log' },

  -- leader prefix
  { '<leader>',   group = 'leader' },
  { '<leader>r',  group = 'run/rename' },
  { '<leader>rn', desc = 'リネーム (LSP)' },
  { '<leader>rt', desc = 'ファイル実行' },
  { '<leader>rs', desc = 'npm start' },
  { '<leader>rr', desc = 'npm test' },
  { '<leader>c',  group = 'color' },
  { '<leader>cc', desc = 'カラーピッカー' },
  { '<leader>ch', desc = 'カラーハイライト切替' },
  { '<leader>ca', desc = 'コードアクション' },
  { '<leader>f',  desc = 'フォーマット' },
  { '<leader>e',  desc = '診断フロート表示' },
})

-- s キーの <Nop> を which-key トリガーで上書き
-- which-key の triggers 設定パースが機能しないため、内部と同じ方法で直接登録
vim.keymap.set('n', 's', function()
  require('which-key.state').start({ keys = 's' })
end, { nowait = true, desc = 'which-key-trigger' })
