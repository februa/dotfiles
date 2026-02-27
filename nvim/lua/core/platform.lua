-- プラットフォーム検出（単一ソース）
-- vim.fn.has() を使用: Neovim 組み込みの OS 判定
-- TOML 側の if = 'has("win32")' と同じ意味論で統一

local M = {}

M.is_windows = (vim.fn.has('win32') == 1)
M.is_macos   = (vim.fn.has('mac') == 1)
M.is_linux   = (vim.fn.has('unix') == 1 and not M.is_macos)
M.is_unix    = (vim.fn.has('unix') == 1)

return M
