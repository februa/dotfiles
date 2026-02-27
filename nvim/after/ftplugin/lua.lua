-- Lua: 2スペースインデント + マーカー折りたたみ + 自動インデント無効
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.foldmethod = "marker"
vim.opt_local.indentexpr = ""              -- 組み込みインデント式を無効化
vim.opt_local.autoindent = false           -- 自動インデントを無効化
vim.opt_local.smartindent = false          -- スマートインデントを無効化
