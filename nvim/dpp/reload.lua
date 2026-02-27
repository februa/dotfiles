-- dpp プラグインのリロード（再起動不要の in-place リロード）
local utils = require('dpp.utils')
local dbg = require('config.debug')
local M = {}

--- プラグインの in-place リロード
function M.dpp_reload()
  dbg.log('reload', 'dpp_reload start')
  local safe = utils.safe

  -- プラグイン関連のモジュールキャッシュを全クリア
  utils.clear_module_cache()
  dbg.log('reload', 'clear_module_cache done')

  -- state 読み込み（startup.vim を source して runtimepath 等を設定）
  safe("load_state", function()
    vim.fn["dpp#min#load_state"](utils.dpp_base)
  end)
  -- load_state の startup.vim が runtimepath を上書きするため必須リポジトリを再追加
  utils.prepend_repos_to_rtp()
  dbg.log('reload', 'load_state + prepend_repos done')

  -- .dpp/lua/ を package.path に追加（vim.loader.reset() 後のキャッシュ不整合を回避）
  utils.add_dpp_lua_to_path()

  -- カラースキームを適用
  safe("colorscheme", function() require('plugins.colorscheme') end)
  dbg.log('reload', 'colorscheme applied')
  -- startup.vim が load_state 中に lualine を setup するが、
  -- その時点ではカラースキームが未適用のため透明になる。
  -- カラースキーム適用後に lualine を再 setup して修正
  package.loaded['plugins.lualine'] = nil
  safe("lualine", function() require('plugins.lualine') end)
  dbg.log('reload', 'lualine re-setup done')

  -- インストール中フラグをクリア
  _G._dpp_installing = nil

  safe("dpp#source", function() vim.fn["dpp#source"]() end)
  dbg.log('reload', 'dpp#source done')

  -- dpp#source() は既にソース済みプラグインの hook_source を再実行しないため、
  -- mason-lspconfig.setup() 等を明示的に再実行する。
  for name in pairs(package.loaded) do
    if name:match('^mason%-lspconfig') then
      package.loaded[name] = nil
    end
  end
  safe("plugins.lsp", function() require('plugins.lsp') end)
  safe("plugins.cmp", function() require('plugins.cmp') end)
  dbg.log('reload', 'plugins.lsp + plugins.cmp re-require done')

  -- 新規プラグインの plugin/ ファイルをソース（既存は g:loaded_xxx ガードで重複回避）
  safe("runtime_plugins", function()
    vim.cmd('runtime! plugin/**/*.vim plugin/**/*.lua')
    vim.cmd('runtime! after/plugin/**/*.vim after/plugin/**/*.lua')
  end)
  dbg.log('reload', 'runtime plugins sourced')

  safe("filetype", function()
    vim.cmd('filetype plugin indent on')
    if vim.bo.filetype ~= '' then
      vim.cmd('doautocmd FileType')
    end
  end)
  dbg.log('reload', 'filetype re-enabled')

  -- インストール中に変更した UI 設定を復元
  vim.o.more = true

  vim.notify("Plugins reloaded!", vim.log.levels.INFO)
  dbg.log('reload', 'dpp_reload complete')

  -- mason LSP サーバー自動インストール
  M._mason_lsp_install()
end

--- mason LSP サーバーの自動インストール（遅延実行）
function M._mason_lsp_install()
  local safe = utils.safe
  local sep = package.config:sub(1, 1)
  local settings = require('config.settings')

  vim.defer_fn(function()
    dbg.log('reload', 'mason: starting LSP server check')
    safe("mason_lsp_install", function()
      -- mason.nvim のソースリポジトリパスを dpp API で取得し package.path に追加
      local mason_plugin = vim.fn["dpp#get"]("mason.nvim")
      if mason_plugin and mason_plugin.path then
        local mason_lua = (mason_plugin.path .. "/lua"):gsub("/", sep)
        if not package.path:find(mason_lua, 1, true) then
          package.path = mason_lua .. sep .. "?.lua;"
                       .. mason_lua .. sep .. "?" .. sep .. "init.lua;"
                       .. package.path
        end
      end
      -- registry API でバックグラウンドインストール（UI を開かない）
      local registry = require('mason-registry')
      registry.refresh(function()
        vim.schedule(function()
          local installing = 0
          local installed = 0
          for _, s in ipairs(settings.lsp_servers) do
            local ok_pkg, pkg = pcall(registry.get_package, s.mason_pkg)
            if ok_pkg and not pkg:is_installed() then
              installing = installing + 1
              dbg.log('reload', 'mason: installing ' .. s.mason_pkg)
              vim.notify("Installing " .. s.mason_pkg .. "...", vim.log.levels.INFO)
              pkg:install():once('closed', vim.schedule_wrap(function()
                installed = installed + 1
                dbg.log('reload', 'mason: ' .. s.mason_pkg .. ' installed (' .. installed .. '/' .. installing .. ')')
                vim.notify(s.mason_pkg .. " installed (" .. installed .. "/" .. installing .. ")", vim.log.levels.INFO)
                -- 全サーバーのインストール完了後に LSP を起動
                if installed >= installing then
                  for name in pairs(package.loaded) do
                    if name:match('^mason%-lspconfig') then
                      package.loaded[name] = nil
                    end
                  end
                  package.loaded['plugins.lsp'] = nil
                  pcall(require, 'plugins.lsp')
                  if vim.bo.filetype ~= '' then
                    vim.cmd('doautocmd FileType')
                  end
                end
              end))
            end
          end
        end)
      end)
    end)
  end, 2000)
end

return M
