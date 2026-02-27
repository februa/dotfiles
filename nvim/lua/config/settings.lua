-- 集約設定: ハードコード値を一元管理
local M = {}

-- カラースキーム
-- 'catppuccin' | 'wisteria' | 'tokyonight'
M.colorscheme = 'wisteria'

-- LSP サーバーリスト
-- lsp: vim.lsp.config / mason-lspconfig のサーバー名
-- mason_pkg: mason-registry のパッケージ名
M.lsp_servers = {
  { lsp = 'pyright', mason_pkg = 'pyright' },
  { lsp = 'ts_ls', mason_pkg = 'typescript-language-server' },
  { lsp = 'clangd', mason_pkg = 'clangd' },
}

return M
