-- avante.nvim AI アシスタント設定
local platform = require('core.platform')

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
if not avante_lib_ok then return end
avante_lib.load()

-- avante.setup() は auth_type='max' (OAuth PKCE) の場合、
-- setup 中に vim.ui.select() を呼んで認証フローを開始する。
-- startup.vim のソース中（dpp#min#load_state 内の try-catch）では
-- UI が未初期化のため vim.ui.select が失敗し、load_state 全体が失敗する。
-- vim.schedule() で遅延実行し、イベントループ開始後に実行させることで回避。
-- (初回認証のみブラウザが開く。トークンはキャッシュされ以降の起動では不要)
-- 初回インストール中は依存プラグイン(plenary等)が未クローンの場合があるため pcall
vim.schedule(function()
  local ok, avante = pcall(require, 'avante')
  if not ok then return end
  avante.setup({
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
  })
end)
