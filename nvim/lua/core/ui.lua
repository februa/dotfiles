-- フォールバック UI（拡張機能無効時のステータスライン + カラースキーム）
-- vim.g.load_extensions = false の場合に読み込まれる

-- カラースキーム（組み込み）
vim.cmd.colorscheme('vim')

-- ステータスライン {{{
vim.opt.laststatus = 2                    -- ステータスラインを常に表示

-- ハイライトグループ定義
local highlights = {
  StatusLine     = { fg = "#abb2bf", bg = "#282c34" },
  StatusLineMode = { fg = "#282c34", bg = "#abb2bf", bold = true },
  StatusLineFile = { fg = "#abb2bf", bg = "#282c34" },
  StatusLineFlag = { fg = "#e06c75", bg = "#282c34" },
  StatusLineInfo = { fg = "#c678dd", bg = "#282c34" },
  StatusLineNC   = { fg = "#5c6370", bg = "#282c34" },
}

for group, opts in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, opts)
end

-- モード別色定義
local mode_colors = {
  n = "#abb2bf",      -- NORMAL: グレー
  i = "#61afef",      -- INSERT: 青
  v = "#e06c75",      -- VISUAL: 赤
  V = "#e06c75",      -- V-LINE: 赤
  ["\22"] = "#e06c75", -- V-BLOCK: 赤
  R = "#c678dd",      -- REPLACE: 紫
  c = "#e5c07b",      -- COMMAND: 黄色
}

-- モード切り替え時の色変更
vim.api.nvim_create_augroup("StatusLineModeColor", { clear = true })
vim.api.nvim_create_autocmd("ModeChanged", {
  group = "StatusLineModeColor",
  callback = function()
    local bg = mode_colors[vim.fn.mode()]
    if bg then
      vim.api.nvim_set_hl(0, "StatusLineMode", { fg = "#282c34", bg = bg, bold = true })
    end
  end,
})

-- モード表示関数
function _G.mode_string()
  local mode_map = {
    n = "NORMAL",
    i = "INSERT",
    R = "REPLACE",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    c = "COMMAND",
    s = "SELECT",
    t = "TERMINAL",
  }
  local mode_str = mode_map[vim.fn.mode()] or vim.fn.mode()
  return string.format("%-8s", mode_str)  -- 8文字幅で左詰め
end

-- ステータスライン構築
vim.opt.statusline = ""
  .. "%#StatusLineMode# %{v:lua.mode_string()} "   -- モード表示
  .. "%#StatusLineFile# %F "                       -- ファイル名
  .. "%#StatusLineFlag#%m%r%h%w"                   -- フラグ
  .. "%#StatusLine#"                               -- 中央の空白部分（明示的に指定）
  .. "%="                                          -- 右寄せ開始
  .. "%#StatusLineInfo#[%{&filetype}]"             -- ファイルタイプ
  .. "[%{&fileencoding}]"                          -- エンコーディング
  .. "[%{&fileformat}]"                            -- ファイルフォーマット
  .. "[%l/%L] "                                    -- 行番号
-- }}}
