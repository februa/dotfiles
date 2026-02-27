-- nvim-cmp 補完設定（NvChad 風スタイリング）
local cmp = require('cmp')

-- dpp.vim は after/plugin/ を自動実行しないため、
-- ソースプラグインの after/plugin/ を明示的に source する
for _, name in ipairs({'cmp_nvim_lsp', 'cmp_buffer', 'cmp_path', 'cmp_vsnip'}) do
  local after_files = vim.api.nvim_get_runtime_file('after/plugin/' .. name .. '.lua', true)
  for _, f in ipairs(after_files) do
    dofile(f)
  end
end

-- Nerd Font アイコン（NvChad 準拠、lspkind 不要）
local kind_icons = {
  Text          = '󰉿',
  Method        = '󰆧',
  Function      = '󰊕',
  Constructor   = '',
  Field         = '󰜢',
  Variable      = '󰀫',
  Class         = '󰠱',
  Interface     = '',
  Module        = '',
  Property      = '󰜢',
  Unit          = '󰑭',
  Value         = '󰎠',
  Enum          = '',
  Keyword       = '󰌋',
  Snippet       = '',
  Color         = '󰏘',
  File          = '󰈚',
  Reference     = '󰈇',
  Folder        = '󰉋',
  EnumMember    = '',
  Constant      = '󰏿',
  Struct        = '󰙅',
  Event         = '',
  Operator      = '󰆕',
  TypeParameter = '󰊄',
}

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },

  window = {
    completion = cmp.config.window.bordered({
      border = 'rounded',
      winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder',
      scrollbar = false,
      side_padding = 0,
    }),
    documentation = cmp.config.window.bordered({
      border = 'rounded',
      winhighlight = 'Normal:CmpDoc,FloatBorder:CmpDocBorder',
    }),
  },

  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(_, item)
      local icon = kind_icons[item.kind] or ''
      local kind = item.kind
      item.menu = kind
      item.menu_hl_group = 'CmpItemMenu'
      item.kind = ' ' .. icon .. ' '
      item.kind_hl_group = 'CmpItemKind' .. kind
      return item
    end,
  },

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),

  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
  }),
})
