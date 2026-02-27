-- 基本キーマップ（プラグイン非依存）

vim.g.mapleader = "\\"                    -- リーダーキーをバックスラッシュに設定

-- 表示行単位での移動
vim.keymap.set("v", "j", "gj")            -- ビジュアルモードで表示行単位で下移動
vim.keymap.set("v", "k", "gk")            -- ビジュアルモードで表示行単位で上移動

-- 矢印キーをjkにマッピング（再帰的）
vim.keymap.set("n", "<Up>", "k", { remap = true })
vim.keymap.set("n", "<Down>", "j", { remap = true })
vim.keymap.set("v", "<Up>", "k", { remap = true })
vim.keymap.set("v", "<Down>", "j", { remap = true })

vim.keymap.set("n", "s", "<Nop>")         -- sをプレフィックスとして使うため無効化

-- ペイン移動 (s + hjkl)
vim.keymap.set("n", "sh", "<C-w>h")      -- 左のペインに移動
vim.keymap.set("n", "sj", "<C-w>j")      -- 下のペインに移動
vim.keymap.set("n", "sk", "<C-w>k")      -- 上のペインに移動
vim.keymap.set("n", "sl", "<C-w>l")      -- 右のペインに移動

vim.keymap.set("n", "Y", "y$")            -- Yを行末までヤンクに変更
vim.keymap.set("n", "Q", "gq")            -- Qを整形コマンドに変更

-- インデント操作
vim.keymap.set("n", ">", ">>")            -- ノーマルモードで>を1行インデント
vim.keymap.set("n", "<", "<<")            -- ノーマルモードで<を1行アンインデント
vim.keymap.set("x", ">", ">gv")           -- ビジュアルモードでインデント後も選択維持
vim.keymap.set("x", "<", "<gv")           -- ビジュアルモードでアンインデント後も選択維持

vim.keymap.set("n", "ZZ", "<Nop>")        -- ZZを無効化（誤操作防止）

-- 素早くエスケープ
vim.keymap.set("i", "jj", "<ESC>")        -- 挿入モードでjj連打でエスケープ
vim.keymap.set("c", "j", function()       -- コマンドラインモードでjj連打でエスケープ
  if vim.fn.getcmdline():sub(vim.fn.getcmdpos() - 1, vim.fn.getcmdpos() - 1) == "j" then
    return "<BS><C-c>"
  else
    return "j"
  end
end, { expr = true })
