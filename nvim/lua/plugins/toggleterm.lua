-- toggleterm 設定
local platform = require('core.platform')

require('toggleterm').setup({
  open_mapping = [[<C-\>]],
  direction = 'horizontal',
  size = 15,
  shade_terminals = false,
  shell = platform.is_windows and 'pwsh' or (vim.fn.executable('bash') == 1 and 'bash' or 'sh'),
  start_in_insert = true,
  persist_size = true,
  close_on_exit = false,
})

-- ターミナルモードのキーマップ
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Terminal: normal mode' })
vim.keymap.set('t', 'jj', [[<C-\><C-n>]], { desc = 'Terminal: normal mode (jj)' })

-- カレントファイルを実行（.ts → npx tsx, .js → node）
vim.keymap.set('n', '<Leader>rt', function()
  local file = vim.fn.expand('%:p')
  local ext = vim.fn.expand('%:e')
  local cmd
  if ext == 'ts' or ext == 'tsx' then
    cmd = 'npx tsx ' .. vim.fn.shellescape(file)
  else
    cmd = 'node ' .. vim.fn.shellescape(file)
  end
  require('toggleterm').exec(cmd)
end, { desc = 'Run current file (node/tsx)' })

-- npm start（プロジェクトルート検出）
vim.keymap.set('n', '<Leader>rs', function()
  local root = vim.b.npm_root
  if root then
    require('toggleterm').exec('cd ' .. vim.fn.shellescape(root) .. '; npm start')
  else
    vim.notify('package.json が見つかりません', vim.log.levels.WARN)
  end
end, { desc = 'npm start (project root)' })

-- npm test
vim.keymap.set('n', '<Leader>rr', function()
  local root = vim.b.npm_root
  if root then
    require('toggleterm').exec('cd ' .. vim.fn.shellescape(root) .. '; npm test')
  else
    require('toggleterm').exec('npm test')
  end
end, { desc = 'npm test' })
