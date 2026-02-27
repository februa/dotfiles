-- lualine 設定 (bubbles style)
-- セパレータに丸型グリフ(U+E0B4/U+E0B6)を使い、両端をバブル状にするレイアウト
-- 色はカラースキームのテーマに委ねる
local settings = require('config.settings')

local lualine_themes = {
  catppuccin = 'iceberg',
  wisteria   = 'wisteria',
  tokyonight = 'tokyonight',
}

-- Avante サイドバー用 extension: mode + filetype のみ表示
local avante_extension = {
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '', right = ''}, right_padding = 2 },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
      {'filetype', separator = { left = '', right = ''}},
    },
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {'filetype'},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  filetypes = { 'Avante', 'AvanteInput', 'AvanteSelectedFiles' },
}

require('lualine').setup({
  options = {
    theme = lualine_themes[settings.colorscheme] or 'auto',
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '' }, right_padding = 2 },
    },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {
      { 'filename', path = 1 },
      '%=',
    },
    lualine_x = {},
    lualine_y = { 'filetype', 'encoding', 'progress' },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { { 'filename', path = 1 } },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  extensions = { avante_extension },
})
