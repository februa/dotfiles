-- ddu.vim 設定
local M = {}

--- hook_add: グローバルキーマップ（プラグイン読み込み前に登録）
function M.hook_add()
  local opts = { silent = true }

  -- sN: カレントバッファのディレクトリでファイル検索（ファイル名表示）
  vim.keymap.set('n', 'sN', function()
    vim.fn['ddu#start']({
      name = 'files',
      sources = {{ name = 'file_rec', params = { path = vim.fn.expand('%:p:h') }}},
      sourceOptions = { file_rec = { columns = { 'icon_filename' }}},
    })
  end, opts)

  -- s;: バッファ一覧（アイコン付き）
  vim.keymap.set('n', 's;', function()
    vim.fn['ddu#start']({
      name = 'buffer',
      sources = {{ name = 'buffer' }},
      sourceOptions = { buffer = { columns = { 'icon_filename' }}},
    })
  end, opts)

  -- sm: バッファ + 最近のファイル（アイコン付き、ソース名付き）
  vim.keymap.set('n', 'sm', function()
    vim.fn['ddu#start']({
      name = 'mru',
      sources = {{ name = 'buffer' }, { name = 'file_old' }},
      sourceOptions = {
        buffer = { columns = { 'icon_filename' }},
        file_old = { columns = { 'icon_filename' }},
      },
      uiParams = { ff = { displaySourceName = 'short' }},
    })
  end, opts)

  -- s/: 行検索
  vim.keymap.set('n', 's/', function()
    vim.fn['ddu#start']({ name = 'line', sources = {{ name = 'line' }}})
  end, opts)

  -- sg: grep (ripgrep)
  vim.keymap.set('n', 'sg', function()
    local pattern = vim.fn.input('grep: ')
    if pattern == '' then return end
    vim.fn['ddu#start']({
      name = 'grep',
      sources = {{ name = 'rg', params = { input = pattern }}},
    })
  end, opts)

  -- sn: ファイラー（カレントバッファのディレクトリを画面下スプリットで表示）
  vim.keymap.set('n', 'sn', function()
    vim.fn['ddu#start']({
      name = 'filer',
      ui = 'filer',
      sources = {{ name = 'file', params = {} }},
      sourceOptions = { file = { path = vim.fn.expand('%:p:h'), columns = { 'icon_filename' }}},
      uiParams = {
        filer = {
          split = 'horizontal',
          splitDirection = 'botright',
          winHeight = 15,
          sortTreesFirst = true,
        },
      },
      actionOptions = {
        narrow = { quit = false },
      },
      kindOptions = {
        file = { defaultAction = 'open' },
      },
    })
  end, opts)
end

--- hook_source: ddu グローバル設定
function M.hook_source()
  vim.fn['ddu#custom#patch_global']({
    ui = 'ff',
    uiParams = {
      ff = {
        split = 'horizontal',
        splitDirection = 'botright',
        winHeight = 15,
        prompt = '>>> ',
        previewSplit = 'vertical',
        previewHeight = 20,
        autoAction = { name = 'preview' },
        autoResize = true,
      },
    },
    sourceOptions = {
      _ = {
        matchers = { 'matcher_substring' },
        ignoreCase = true,
      },
    },
    filterParams = {
      matcher_substring = {
        highlightMatched = 'Search',
      },
    },
    kindOptions = {
      file = {
        defaultAction = 'open',
      },
    },
  })
end

return M
