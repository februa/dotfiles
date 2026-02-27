local M = {}

--- notebook_path を取得（ZK_NOTEBOOK_DIR 環境変数 → カレントディレクトリ）
local function notebook_path()
  return vim.env.ZK_NOTEBOOK_DIR or vim.fn.getcwd()
end

function M.setup()
  require('zk').setup({
    picker = 'select',
    lsp = {
      config = {
        cmd = { 'zk', 'lsp' },
        name = 'zk',
      },
      auto_attach = { enabled = true, filetypes = { 'markdown' } },
    },
  })
end

--- 選択されたノートを画面下スプリットで開く
local function open_in_split(notes)
  for _, note in ipairs(notes) do
    vim.cmd('below split ' .. vim.fn.fnameescape(note.absPath))
  end
end

--- pick_notes + 下スプリットで開くヘルパー
local function pick_and_open(options, picker_options)
  require('zk').pick_notes(options, picker_options, function(notes)
    if picker_options and picker_options.multi_select == false then
      notes = { notes }
    end
    open_in_split(notes)
  end)
end

function M.new_note()
  local title = vim.fn.input('Note title: ')
  if title == '' then return end
  require('zk').new({ notebook_path = notebook_path(), title = title, edit = false }, function(_, path)
    if path then
      vim.cmd('below split ' .. vim.fn.fnameescape(path))
    end
  end)
end

function M.list_notes()
  pick_and_open({ notebook_path = notebook_path(), sort = { 'modified' } }, { title = 'Notes' })
end

function M.list_tags()
  require('zk').pick_tags({ notebook_path = notebook_path() }, { title = 'Tags' }, function(tags)
    tags = type(tags) == 'table' and not tags.name and tags or { tags }
    pick_and_open(
      { notebook_path = notebook_path(), tags = vim.tbl_map(function(t) return t.name end, tags) },
      { title = 'Notes (filtered by tag)' }
    )
  end)
end

function M.find_notes()
  local query = vim.fn.input('Search notes: ')
  if query == '' then return end
  pick_and_open({ notebook_path = notebook_path(), match = { query } }, { title = 'Search: ' .. query })
end

function M.list_links()
  pick_and_open(
    { notebook_path = notebook_path(), linkedBy = { vim.api.nvim_buf_get_name(0) } },
    { title = 'Links' }
  )
end

function M.list_backlinks()
  pick_and_open(
    { notebook_path = notebook_path(), linkTo = { vim.api.nvim_buf_get_name(0) } },
    { title = 'Backlinks' }
  )
end

return M
