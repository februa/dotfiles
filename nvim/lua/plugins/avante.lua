-- avante.nvim AI アシスタント設定
--
-- 設計方針:
--   hook_source 時は前処理（ffi パッチ等）のみ実行。
--   avante.setup() は :AvanteAuth でのみ実行する。
--   auth_type='max' (OAuth PKCE) は setup 時に認証フローを開始するため、
--   ユーザの明示的なコマンド実行なしにブラウザが開くことを防ぐ。
--
-- 認証フロー:
--   :AvanteAuth → avante.setup(auth_type='max') → OAuth → 認証完了
--
-- コマンド利用:
--   sa* キーマップ / :Avante* コマンド
--     認証済み → そのまま実行
--     未認証   → 通知して終了（OAuth は走らない）

local M = {}
local platform = require('core.platform')

-- ===== 前処理（hook_source 時に即実行）=====

-- Windows: OpenSSL DLL 名が "crypto" ではなく "libcrypto-3-x64" のため
-- ffi.load("crypto") を ffi.load("libcrypto-3-x64") にリダイレクト
-- (pkce.lua が ffi.load("crypto") で OpenSSL をロードしようとするため)
local ffi_ok, ffi = pcall(require, 'ffi')
if ffi_ok and platform.is_windows then
  local _original_ffi_load = ffi.load
  ---@diagnostic disable-next-line: duplicate-set-field
  ffi.load = function(name, ...)
    if name == 'crypto' then
      local ok, lib = pcall(_original_ffi_load, 'libcrypto-3-x64', ...)
      if ok then return lib end
    end
    return _original_ffi_load(name, ...)
  end
end

-- Windows: vim.ui.open が cmd.exe /c start '' URL を使うため、
-- URL 内の & がコマンド区切りとして解釈され OAuth パラメータが欠落する。
-- rundll32 経由なら cmd.exe を通さないため & の問題が発生しない。
if platform.is_windows then
  local _original_vim_ui_open = vim.ui.open
  vim.ui.open = function(path, ...)
    if type(path) == 'string' and path:match('&') then
      return vim.system(
        { 'rundll32', 'url.dll,FileProtocolHandler', path },
        { detach = true }
      )
    end
    return _original_vim_ui_open(path, ...)
  end
end

-- avante_lib.load() は初回インストール中にモジュールが未解決の場合がある
local avante_lib_ok, avante_lib = pcall(require, 'avante_lib')
if avante_lib_ok then
  avante_lib.load()
end

-- ===== setup 設定 =====

local setup_opts = {
  provider = 'claude',
  mode = 'agentic',

  providers = {
    claude = {
      endpoint = 'https://api.anthropic.com',
      model = 'claude-sonnet-4-20250514',
      auth_type = 'max',
      api_key_name = '',
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 20480,
      },
    },
    -- sam で Opus に切替可能（:AvanteSwitchProvider でも選択可）
    -- api_key_name = '' により is_env_set() が true を返し、
    -- モデルセレクタに表示される（OAuth 認証なので API キー不要）
    ['claude-opus'] = {
      __inherited_from = 'claude',
      model = 'claude-opus-4-20250514',
      api_key_name = '',
      timeout = 60000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 32000,
      },
    },
    ['claude-haiku'] = {
      __inherited_from = 'claude',
      model = 'claude-3-5-haiku-20241022',
      api_key_name = '',
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 8192,
      },
    },
    -- 未契約のプロバイダーをモデルセレクタから非表示
    vertex = { hide_in_model_selector = true },
    vertex_claude = { hide_in_model_selector = true },
  },

  acp_providers = {
    ['claude-code'] = {
      command = 'npx',
      args = { '@zed-industries/claude-code-acp' },
      env = {
        NODE_NO_WARNINGS = '1',
      },
    },
  },

  windows = {
    position = 'right',
    width = 30,
    sidebar_header = {
      align = 'center',
      rounded = true,
    },
  },

  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = false,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,
    enable_token_counting = true,
  },

  file_selector = {
    provider = 'native',
  },

  -- native input provider のバグ回避（vim.ui.select → vim.ui.input の誤り）
  -- upstream: avante/ui/input/providers/native.lua
  -- プラグイン更新で native.lua が修正されるまでの防御策として
  -- カスタム関数で vim.ui.input を直接呼ぶ
  input = {
    provider = function(input_obj)
      vim.ui.input({
        prompt = input_obj.title,
        default = input_obj.default,
        completion = input_obj.completion,
      }, input_obj.on_submit)
    end,
  },
}

-- ===== 状態管理 =====

local initialized = false

--- 認証済み（setup 完了）かどうかを返す。
--- @return boolean
function M.is_ready()
  return initialized
end

--- 未認証時にユーザへ通知する。コマンドは実行しない。
--- @return boolean 認証済みなら true
function M.require_auth()
  if initialized then return true end
  vim.notify(
    '[avante] 未認証です。先に :AvanteAuth を実行してください。',
    vim.log.levels.WARN
  )
  return false
end

--- :AvanteAuth 専用。avante.setup() を実行し OAuth フローを開始する。
--- @param on_ready? fun() setup 完了後に実行するコールバック
--- @return boolean
function M.authenticate(on_ready)
  if initialized then
    vim.notify('[avante] 既に認証済みです。', vim.log.levels.INFO)
    if on_ready then on_ready() end
    return true
  end

  local ok, avante = pcall(require, 'avante')
  if not ok then
    vim.notify(
      '[avante] モジュールのロードに失敗しました。プラグインが正しくインストールされているか確認してください。',
      vim.log.levels.ERROR
    )
    return false
  end

  -- vim.schedule: dpp#source 内の try-catch 中は UI が未初期化のため
  -- vim.ui.select が失敗する場合がある。イベントループ開始後に実行。
  vim.schedule(function()
    avante.setup(setup_opts)
    initialized = true
    vim.notify('[avante] セットアップ完了。', vim.log.levels.INFO)
    if on_ready then on_ready() end
  end)
  return true
end

-- ===== ユーザーコマンド =====

-- :AvanteAuth — 認証・セットアップを手動実行（唯一の OAuth トリガー）
vim.api.nvim_create_user_command('AvanteAuth', function()
  M.authenticate()
end, { desc = 'Avante: 認証・セットアップ（OAuth フロー開始）' })

return M
