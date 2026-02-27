-- カラースキーム設定
-- init.lua 起動時と dpp_reload() から呼ばれる
-- settings.colorscheme に応じてスキームを切り替える
--
-- 切替方法: lua/config/settings.lua の M.colorscheme を変更
--   'catppuccin' — catppuccin mocha（透過背景、cmp カスタムハイライト付き）
--   'wisteria'   — wisteria（透過背景）
--   'tokyonight' — tokyonight
--
-- 戻り値: true（適用成功）/ false（未インストール等で適用失敗）

local settings = require('config.settings')
local scheme = settings.colorscheme

-- =============================================================
-- catppuccin
-- =============================================================
local function setup_catppuccin()
  -- 既にロード済みのモジュールをクリア（再適用のため）
  for name in pairs(package.loaded) do
    if name:match('^catppuccin') then
      package.loaded[name] = nil
    end
  end

  local ok, catppuccin = pcall(require, 'catppuccin')
  if not ok then return false end

  vim.g.catppuccin_flavour = 'mocha'
  catppuccin.setup({
    flavour = 'mocha',
    transparent_background = true,
    styles = {
      comments = { 'italic' },
      keywords = { 'bold' },
    },
    integrations = {
      treesitter = true,
      native_lsp = { enabled = true },
    },
    custom_highlights = function(colors)
      return {
        LineNr = { fg = '#888888' },
        -- nvim-cmp ポップアップ
        CmpPmenu           = { bg = colors.surface0 },
        CmpSel             = { bg = '#FFA5A6', fg = colors.base },
        CmpDoc             = { bg = colors.surface0 },
        CmpBorder          = { fg = colors.surface2 },
        CmpDocBorder       = { fg = colors.surface2 },
        CmpItemAbbrMatch   = { fg = colors.blue, bold = true },
        CmpItemMenu        = { fg = colors.overlay0, italic = true },
        -- Kind ごとのアイコン色
        CmpItemKindText          = { fg = colors.teal,     bg = colors.surface1 },
        CmpItemKindMethod        = { fg = colors.blue,     bg = colors.surface1 },
        CmpItemKindFunction      = { fg = colors.blue,     bg = colors.surface1 },
        CmpItemKindConstructor   = { fg = colors.sapphire, bg = colors.surface1 },
        CmpItemKindField         = { fg = colors.green,    bg = colors.surface1 },
        CmpItemKindVariable      = { fg = colors.flamingo, bg = colors.surface1 },
        CmpItemKindClass         = { fg = colors.yellow,   bg = colors.surface1 },
        CmpItemKindInterface     = { fg = colors.yellow,   bg = colors.surface1 },
        CmpItemKindModule        = { fg = colors.blue,     bg = colors.surface1 },
        CmpItemKindProperty      = { fg = colors.green,    bg = colors.surface1 },
        CmpItemKindUnit          = { fg = colors.green,    bg = colors.surface1 },
        CmpItemKindValue         = { fg = colors.peach,    bg = colors.surface1 },
        CmpItemKindEnum          = { fg = colors.green,    bg = colors.surface1 },
        CmpItemKindKeyword       = { fg = colors.red,      bg = colors.surface1 },
        CmpItemKindSnippet       = { fg = colors.mauve,    bg = colors.surface1 },
        CmpItemKindColor         = { fg = colors.red,      bg = colors.surface1 },
        CmpItemKindFile          = { fg = colors.blue,     bg = colors.surface1 },
        CmpItemKindReference     = { fg = colors.red,      bg = colors.surface1 },
        CmpItemKindFolder        = { fg = colors.blue,     bg = colors.surface1 },
        CmpItemKindEnumMember    = { fg = colors.red,      bg = colors.surface1 },
        CmpItemKindConstant      = { fg = colors.peach,    bg = colors.surface1 },
        CmpItemKindStruct        = { fg = colors.blue,     bg = colors.surface1 },
        CmpItemKindEvent         = { fg = colors.blue,     bg = colors.surface1 },
        CmpItemKindOperator      = { fg = colors.sky,      bg = colors.surface1 },
        CmpItemKindTypeParameter = { fg = colors.maroon,   bg = colors.surface1 },
      }
    end,
  })

  vim.cmd.colorscheme('catppuccin')

  return true
end

-- =============================================================
-- wisteria
-- =============================================================
local function setup_wisteria()
  for name in pairs(package.loaded) do
    if name:match('^wisteria') then
      package.loaded[name] = nil
    end
  end

  local ok, wisteria = pcall(require, 'wisteria')
  if not ok then return false end

  wisteria.setup({
    transparent = true,
  })

  vim.cmd.colorscheme('wisteria')

  return true
end

-- =============================================================
-- tokyonight
-- =============================================================
local function setup_tokyonight()
  for name in pairs(package.loaded) do
    if name:match('^tokyonight') then
      package.loaded[name] = nil
    end
  end

  local ok, tokyonight = pcall(require, 'tokyonight')
  if not ok then return false end

  tokyonight.setup({
    transparent = true,
  })

  vim.cmd.colorscheme('tokyonight')

  return true
end

-- =============================================================
-- ディスパッチ
-- =============================================================
local schemes = {
  catppuccin = setup_catppuccin,
  wisteria   = setup_wisteria,
  tokyonight = setup_tokyonight,
}

local setup_fn = schemes[scheme]
if not setup_fn then
  vim.api.nvim_echo({{ 'colorscheme: unknown scheme "' .. scheme .. '"', 'ErrorMsg' }}, true, {})
  return false
end

return setup_fn()
