-- treesitter 設定
-- 未インストールのパーサーを自動インストール
local ensure = {
  'typescript', 'tsx', 'lua', 'toml', 'html', 'css',
  'javascript', 'json', 'markdown', 'markdown_inline',
  'vim', 'vimdoc', 'python', 'cpp', 'c',
}

require'nvim-treesitter'.setup {
  install_dir = vim.fn.stdpath('data') .. '/site'
}

-- Windows: gcc を CC に設定（cl.exe が PATH にない場合）
if vim.fn.has('win32') == 1 and vim.fn.executable('cl') == 0 then
  vim.env.CC = 'gcc'
end

-- filetype → パーサー名のマッピング（dpp.vim 環境では自動登録されないため）
vim.treesitter.language.register('tsx', 'typescriptreact')
vim.treesitter.language.register('tsx', 'javascript.jsx')
vim.treesitter.language.register('typescript', 'typescript')
vim.treesitter.language.register('javascript', 'javascript')
vim.treesitter.language.register('markdown', 'markdown')

-- plugin/nvim-treesitter.lua を手動ソース（:TSInstall 等のコマンド登録）
local plugin_file = vim.api.nvim_get_runtime_file('plugin/nvim-treesitter.lua', false)
if plugin_file and plugin_file[1] then
  vim.cmd.source(plugin_file[1])
end

-- markdown バッファで treesitter ハイライトを有効化
-- Neovim 0.11 では自動有効化されないため明示的に開始する
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args)
    vim.treesitter.start(args.buf, 'markdown')
  end,
})

-- 未インストールのパーサーを自動インストール
local installed = {}
for _, lang in ipairs(require('nvim-treesitter.config').get_installed('parsers')) do
  installed[lang] = true
end
for _, lang in ipairs(ensure) do
  if not installed[lang] then
    vim.cmd('TSInstall ' .. lang)
  end
end
