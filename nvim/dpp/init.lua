-- dpp.vim エントリポイント
-- 1. 必須リポジトリを runtimepath に追加
-- 2. 未クローンならブートストラップ
-- 3. 早期カラースキーム読み込み
-- 4. DenopsReady でコマンド登録・state ロード

-- dpp/ は lua/ 配下ではないため、require('dpp.xxx') が解決できるように
-- config ルートを package.path に追加する
local config_dir = vim.fn.stdpath('config')
if not package.path:find(config_dir, 1, true) then
  package.path = config_dir .. '/?.lua;' .. config_dir .. '/?/init.lua;' .. package.path
end

local utils = require('dpp.utils')
local dbg = require('config.debug')

-- カスタム Lua ローダーを登録（dpp_reload() より前に必要）
utils.register_rtp_loader()
dbg.log('dpp', 'register_rtp_loader done')

-- 既存のリポジトリのみ runtimepath に追加
utils.prepend_repos_to_rtp()
dbg.log('dpp', 'prepend_repos_to_rtp: ' .. #utils.repos .. ' repos')

-- 未クローンのリポジトリがあればブートストラップ
local bootstrap = require('dpp.bootstrap')
local needs_clone = bootstrap.ensure_repos()
dbg.log('dpp', 'bootstrap: ' .. (needs_clone and 'cloning started' or 'all repos present'))

-- Deno チェック
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.executable("deno") == 0 then
      vim.notify("Deno is not installed! Please install Deno to use dpp.vim.", vim.log.levels.ERROR)
      vim.notify("Run: irm https://deno.land/install.ps1 | iex", vim.log.levels.INFO)
    end
  end,
})

-- 早期カラースキーム読み込み（dpp のマージ済みプラグインディレクトリから）
local dpp_runtime = utils.dpp_base .. "/" .. vim.fn.fnamemodify(vim.v.progname, ":r") .. "/.dpp"
if vim.fn.isdirectory(dpp_runtime) == 1 then
  vim.opt.runtimepath:prepend(dpp_runtime)
  dbg.log('dpp', 'dpp_runtime prepended: ' .. dpp_runtime)
else
  dbg.log('dpp', 'dpp_runtime not found: ' .. dpp_runtime, vim.log.levels.WARN)
end

if not require('plugins.colorscheme') then
  vim.cmd.colorscheme("vim")
  dbg.log('dpp', 'colorscheme: fallback to vim')
else
  dbg.log('dpp', 'colorscheme: applied')
end

-- DenopsReady: dpp のメインフロー
vim.api.nvim_create_autocmd("User", {
  pattern = "DenopsReady",
  callback = function()
    dbg.log('dpp', 'DenopsReady fired')
    vim.notify("Denops is ready!", vim.log.levels.INFO)

    -- ユーザーコマンドを登録
    local commands = require('dpp.commands')
    commands.register()
    dbg.log('dpp', 'user commands registered')

    -- state をロード
    vim.notify("Loading dpp state...", vim.log.levels.INFO)
    if vim.loader and vim.loader.reset then
      vim.loader.reset()
    end
    local load_ok, load_result = pcall(vim.fn["dpp#min#load_state"], utils.dpp_base)
    if not load_ok then
      vim.notify("dpp#min#load_state error: " .. tostring(load_result), vim.log.levels.ERROR)
      dbg.log('dpp', 'load_state: error - ' .. tostring(load_result), vim.log.levels.ERROR)
      load_result = 1
    end

    if load_result ~= 0 then
      -- キャッシュなし → state 構築 → 自動インストール → リロード
      dbg.log('dpp', 'load_state: cache miss → _first_time_build')
      _first_time_build()
    else
      -- キャッシュあり → キャッシュから読み込み
      dbg.log('dpp', 'load_state: cache hit → _cached_load')
      _cached_load()
    end
  end,
})

--- 初回ビルド: state 構築 → 自動インストール → state 再構築 → リロード
function _first_time_build()
  local reload = require('dpp.reload')

  dbg.log('dpp', '_first_time_build: starting make_state')
  vim.notify("Building state...", vim.log.levels.INFO)
  local completed = false
  vim.api.nvim_create_autocmd("User", {
    pattern = "Dpp:makeStatePost",
    callback = function()
      completed = true
      dbg.log('dpp', '_first_time_build: Dpp:makeStatePost received')
      if vim.loader and vim.loader.reset then
        vim.loader.reset()
      end
      vim.fn["dpp#min#load_state"](utils.dpp_base)

      -- 未インストールのプラグインがあれば自動インストール
      local has_uninstalled = vim.fn["dpp#sync_ext_action"]('installer', 'getNotInstalled')
      dbg.log('dpp', '_first_time_build: ' .. (has_uninstalled and #has_uninstalled or 0) .. ' uninstalled plugins')

      if has_uninstalled and #has_uninstalled > 0 then
        vim.notify("Auto-installing " .. #has_uninstalled .. " plugins...", vim.log.levels.INFO)
        dbg.log('dpp', '_first_time_build: starting install')
        _G._dpp_installing = true
        vim.o.more = false

        vim.api.nvim_create_autocmd("User", {
          pattern = "Dpp:ext:installer:updateDone",
          callback = function()
            dbg.log('dpp', '_first_time_build: install done, rebuilding state')
            vim.notify("Install done. Rebuilding state...", vim.log.levels.INFO)
            if vim.loader and vim.loader.reset then
              vim.loader.reset()
            end
            utils.clear_module_cache()

            local reload_done = false
            vim.api.nvim_create_autocmd("User", {
              pattern = "Dpp:makeStatePost",
              callback = function()
                reload_done = true
                dbg.log('dpp', '_first_time_build: post-install make_state done → dpp_reload')
                reload.dpp_reload()
              end,
              once = true,
            })
            local ms_ok, ms_err = pcall(vim.fn["dpp#make_state"], utils.dpp_base, utils.dpp_config_path)
            if not ms_ok then
              vim.notify("make_state error: " .. tostring(ms_err), vim.log.levels.ERROR)
              dbg.log('dpp', '_first_time_build: post-install make_state error - ' .. tostring(ms_err), vim.log.levels.ERROR)
              reload.dpp_reload()
            else
              vim.defer_fn(function()
                if not reload_done then
                  dbg.log('dpp', '_first_time_build: post-install make_state timeout', vim.log.levels.WARN)
                  vim.notify("make_state timeout! Forcing dpp_reload()...", vim.log.levels.WARN)
                  reload.dpp_reload()
                end
              end, 60000)
            end
          end,
          once = true,
        })

        vim.cmd("call dpp#async_ext_action('installer', 'install')")
      else
        dbg.log('dpp', '_first_time_build: no uninstalled plugins, dpp#source')
        vim.fn["dpp#source"]()
        vim.cmd("filetype plugin indent on")
        vim.notify("dpp.vim initialized!", vim.log.levels.INFO)
      end
    end,
    once = true,
  })

  vim.fn["dpp#make_state"](utils.dpp_base, utils.dpp_config_path)
  vim.defer_fn(function()
    if not completed then
      dbg.log('dpp', '_first_time_build: make_state timeout (60s)', vim.log.levels.ERROR)
      vim.notify("dpp#make_state timeout! Check :messages for denops errors", vim.log.levels.ERROR)
    end
  end, 60000)
end

--- キャッシュからの読み込み
function _cached_load()
  dbg.log('dpp', '_cached_load: start')
  -- load_state の startup.vim が runtimepath を上書きするため
  -- 必須プラグインを runtimepath に再追加
  utils.prepend_repos_to_rtp()
  dbg.log('dpp', '_cached_load: prepend_repos_to_rtp done')
  -- startup.vim が filetype off するため再有効化
  vim.cmd("filetype plugin indent on")
  -- hook_source を実行するため dpp#source() を呼ぶ
  local ok, err = pcall(vim.fn["dpp#source"])
  if ok then
    dbg.log('dpp', '_cached_load: dpp#source done')
    -- DenopsReady は Neovim 初期化完了後に発火するため、
    -- startup.vim で runtimepath に追加された merged=false プラグインの
    -- plugin/ ファイルが自動ソースされない。明示的に runtime! で実行する。
    vim.cmd('runtime! plugin/**/*.vim plugin/**/*.lua')
    vim.cmd('runtime! after/plugin/**/*.vim after/plugin/**/*.lua')
    dbg.log('dpp', '_cached_load: runtime plugins sourced')
    vim.notify("dpp.vim loaded!", vim.log.levels.INFO)
    vim.cmd("echo ''")  -- コマンドラインに残った起動メッセージをクリア
  else
    dbg.log('dpp', '_cached_load: dpp#source error - ' .. tostring(err), vim.log.levels.ERROR)
    vim.notify("dpp#source() error: " .. tostring(err), vim.log.levels.ERROR)
  end
end
