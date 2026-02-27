-- dpp 共通定数・ユーティリティ関数
local M = {}

-- 定数
M.dpp_base = vim.fn.stdpath("data") .. "/dpp"
M.dpp_config_path = vim.fn.stdpath("config") .. "/dpp/load_plugins.ts"

-- 必須リポジトリ
M.repos = {
  { url = "https://github.com/Shougo/dpp.vim", path = M.dpp_base .. "/repos/github.com/Shougo/dpp.vim" },
  { url = "https://github.com/vim-denops/denops.vim", path = M.dpp_base .. "/repos/github.com/vim-denops/denops.vim" },
  { url = "https://github.com/Shougo/dpp-ext-installer", path = M.dpp_base .. "/repos/github.com/Shougo/dpp-ext-installer" },
  { url = "https://github.com/Shougo/dpp-ext-lazy", path = M.dpp_base .. "/repos/github.com/Shougo/dpp-ext-lazy" },
  { url = "https://github.com/Shougo/dpp-ext-toml", path = M.dpp_base .. "/repos/github.com/Shougo/dpp-ext-toml" },
  { url = "https://github.com/Shougo/dpp-protocol-git", path = M.dpp_base .. "/repos/github.com/Shougo/dpp-protocol-git" },
}

--- プラグイン関連のモジュールキャッシュを全クリア
--- vim.* / jit / ffi 等の基盤モジュールは除外
function M.clear_module_cache()
  for name in pairs(package.loaded) do
    if not name:match('^vim%.')
      and not name:match('^_G')
      and name ~= 'vim'
      and name ~= 'jit'
      and not name:match('^jit%.')
      and not name:match('^ffi')
      and not name:match('^bit')
      and not name:match('^string')
      and not name:match('^table')
      and not name:match('^math')
      and not name:match('^io')
      and not name:match('^os')
      and not name:match('^coroutine')
      and not name:match('^package')
      and not name:match('^debug')
    then
      package.loaded[name] = nil
    end
  end
end

--- エラーが起きても次の処理に進む安全ラッパー
--- クラッシュ箇所を :messages で特定可能にする
--- vim.notify ではなく nvim_echo を使用: fidget.nvim が vim.notify を乗っ取ると
--- :messages に記録されなくなるため
---@param label string
---@param fn function
function M.safe(label, fn)
  local dbg = require('config.debug')
  dbg.log('safe', label .. ': start')
  local ok, err = pcall(fn)
  if not ok then
    vim.api.nvim_echo({{"dpp [" .. label .. "]: " .. tostring(err), "ErrorMsg"}}, true, {})
    dbg.log('safe', label .. ': FAILED - ' .. tostring(err), vim.log.levels.ERROR)
  else
    dbg.log('safe', label .. ': ok')
  end
end

--- 必須リポジトリを runtimepath に追加（既存のもののみ）
function M.prepend_repos_to_rtp()
  for _, repo in ipairs(M.repos) do
    if vim.fn.isdirectory(repo.path) == 1 then
      vim.opt.runtimepath:prepend(repo.path)
    end
  end
end

--- runtimepath の lua/ ディレクトリから Lua モジュールを検索するカスタムローダー
--- vim.loader がキャッシュ不整合でサブモジュールを見つけられない場合の安全策
--- NOTE: dpp_reload() より前に登録する必要がある
function M.register_rtp_loader()
  if _G._dpp_rtp_loader then return end
  table.insert(package.loaders, function(modname)
    local relpath = modname:gsub('%.', '/')
    local candidates = {
      'lua/' .. relpath .. '.lua',
      'lua/' .. relpath .. '/init.lua',
    }
    for _, candidate in ipairs(candidates) do
      local files = vim.api.nvim_get_runtime_file(candidate, false)
      if files and files[1] then
        return function()
          return dofile(files[1])
        end
      end
    end
  end)
  _G._dpp_rtp_loader = true
end

--- .dpp/lua/ を package.path に追加
--- vim.loader のキャッシュ不整合を回避するため
function M.add_dpp_lua_to_path()
  local sep = package.config:sub(1, 1)
  local dpp_lua = (M.dpp_base .. "/nvim/.dpp/lua"):gsub("/", sep)
  if not package.path:find(dpp_lua, 1, true) then
    package.path = dpp_lua .. sep .. "?.lua;"
                 .. dpp_lua .. sep .. "?" .. sep .. "init.lua;"
                 .. package.path
  end
end

return M
