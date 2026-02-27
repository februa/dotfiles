-- LSP 設定
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

mason.setup()

-- LSP アタッチ時のキーマップ
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    -- LSP 接続バッファはサイン列を常時表示（診断マーク用）
    vim.wo.signcolumn = 'yes'
    -- ナビゲーション
    --   fd: 定義へジャンプ
    --   fD: 宣言へジャンプ
    --   fi: 実装へジャンプ
    --   fr: 参照一覧
    --   ft: 型定義へジャンプ
    vim.keymap.set('n', 'fd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'fD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'fi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'fr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'ft', vim.lsp.buf.type_definition, opts)
    -- ドキュメント
    --   Space: ホバー（関数の説明等）
    --   C-k: シグネチャヘルプ（引数の型情報等）
    vim.keymap.set('n', '<Space>', vim.lsp.buf.hover, opts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
    -- コードアクション
    --   \rn: リネーム
    --   \ca: コードアクション
    --   \f:  フォーマット
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<Leader>f', function()
      require('conform').format({ async = true, lsp_format = 'fallback' })
    end, opts)
    -- 診断
    --   [d: 前の診断へ
    --   ]d: 次の診断へ
    --   \e: 診断をフロート表示
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
  end,
})

-- 診断表示設定
vim.diagnostic.config({
  virtual_text = { prefix = '●', source = 'if_many' },
  signs = true,
  underline = true,
  update_in_insert = false,
  float = { border = 'rounded', source = 'always' },
})

-- nvim-cmp の追加 capabilities を LSP に渡す
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if ok_cmp_lsp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- サーバー個別設定（vim.lsp.config で宣言的に定義）
vim.lsp.config('pyright', {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'basic',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.config('ts_ls', { capabilities = capabilities })

vim.lsp.config('clangd', { capabilities = capabilities })

-- mason-lspconfig でサーバー自動インストール
-- automatic_enable = true（デフォルト）で自動的に vim.lsp.enable() が呼ばれる
--
-- _G._dpp_installing == true の場合は setup() 全体をスキップ:
--   setup() → mason-registry の非同期コールバックが make_state の .dpp 再構築と
--   競合してモジュール解決エラーになるため。
--   dpp_reload() が _G._dpp_installing をクリアした後に dpp#source() →
--   hook_source で本ファイルが再実行され、正常に setup() が走る。
-- サーバーリストを config/settings.lua から取得（一元管理）
local settings = require('config.settings')
local servers = vim.tbl_map(function(s) return s.lsp end, settings.lsp_servers)

if not _G._dpp_installing then
  mason_lspconfig.setup({
    ensure_installed = servers,
  })

  -- automatic_enable は既にインストール済みのサーバーのみ vim.lsp.enable() する。
  -- 未インストールのサーバーも含めて明示的に enable しておくことで、
  -- FileType autocmd を登録し、mason インストール完了後に doautocmd FileType で
  -- LSP がアタッチされるようにする。
  vim.lsp.enable(servers)

  -- mason が LSP サーバーをインストール完了した後、
  -- 既に開いているバッファに LSP をアタッチするため FileType を再発火
  local ok_reg, registry = pcall(require, 'mason-registry')
  if ok_reg then
    registry:on('package:install:success', vim.schedule_wrap(function()
      if vim.bo.filetype ~= '' then
        vim.cmd('doautocmd FileType')
      end
    end))
  end
end
