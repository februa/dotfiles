-- 基本 autocmd（プラグイン非依存）

-- 外部変更の自動検出 {{{
-- フォーカス復帰・バッファ切替・カーソル停止時に checktime
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("AutoChecktime", { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- 外部変更検出時の処理: 未変更バッファは自動再読み込み、変更中バッファは確認
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = "AutoChecktime",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = "AutoChecktime",
  callback = function(args)
    -- 未変更バッファは autoread に任せる（自動再読み込み）
    if not vim.bo[args.buf].modified then
      return
    end
    -- 変更中バッファは確認ダイアログを表示
    local filename = vim.fn.fnamemodify(args.file, ":~:.")
    local choice = vim.fn.confirm(
      filename .. " has been modified outside and has unsaved changes.\nWhat do you want to do?",
      "&Reload (discard changes)\n&Save as...\n&Ignore",
      3
    )
    if choice == 1 then
      vim.cmd("edit!")
    elseif choice == 2 then
      vim.ui.input({ prompt = "Save as: ", default = args.file }, function(new_path)
        if new_path and new_path ~= "" then
          vim.cmd("saveas " .. vim.fn.fnameescape(new_path))
          vim.cmd("edit!")  -- 元バッファを外部変更で再読み込み
        end
      end)
    end
    -- choice == 3 (Ignore): 何もしない
    return true  -- デフォルトの警告メッセージを抑制
  end,
})
-- }}}

-- FastFold（編集中は手動折りたたみ、保存時に再計算） {{{
local fastfold_group = vim.api.nvim_create_augroup("MyAutoCmd", { clear = false })

vim.api.nvim_create_autocmd({"TextChangedI", "TextChanged"}, {
  group = fastfold_group,
  pattern = "*",
  callback = function()
    if vim.wo.foldenable and vim.wo.foldmethod ~= "manual" then
      vim.b.foldmethod_save = vim.wo.foldmethod
      vim.wo.foldmethod = "manual"        -- 編集中は手動折りたたみに切り替え
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = fastfold_group,
  pattern = "*",
  callback = function()
    if vim.wo.foldmethod == "manual" and vim.b.foldmethod_save ~= nil then
      vim.wo.foldmethod = vim.b.foldmethod_save  -- 保存後に元の折りたたみ方法に戻す
      vim.cmd("normal! zx")               -- 折りたたみを再計算
    end
  end,
})
-- }}}

-- ビュー自動保存・復元 {{{
-- 特定のファイルタイプでビューを自動保存・復元
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = {"*.md", "*.txt", "*.lua"},
  command = "silent! mkview"              -- ウィンドウを閉じる時にビューを保存
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = {"*.md", "*.txt", "*.lua"},
  command = "silent! loadview"            -- ウィンドウを開く時にビューを読み込み
})
-- }}}

-- ディレクトリ自動作成 {{{
-- ファイルを開いた際にディレクトリが存在しなければ作成を確認
local function auto_mkdir(dir, force)
  if vim.fn.isdirectory(dir) == 0 then
    if force or vim.fn.input(string.format('"%s" does not exist. Create? [y/N]', dir)):lower():match("^y") then
      vim.fn.mkdir(dir, "p")
    end
  end
end

vim.api.nvim_create_augroup("vimrc-auto-mkdir", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = "vimrc-auto-mkdir",
  pattern = "*",
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    auto_mkdir(dir, vim.v.cmdbang == 1)   -- :w! の場合は確認なしで作成
  end,
})
-- }}}

-- ユーティリティコマンド {{{
-- :Messages — :messages の内容をクリップボードにコピー
vim.api.nvim_create_user_command("Messages", function()
  vim.cmd("redir @+ | silent messages | redir END")
  vim.notify("Copied :messages to clipboard", vim.log.levels.INFO)
end, { desc = "Copy :messages output to clipboard" })
-- }}}
