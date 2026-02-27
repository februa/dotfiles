-- dpp リポジトリのブートストラップ（初回クローン）
local utils = require('dpp.utils')
local dbg = require('config.debug')
local M = {}

--- 非同期 git clone
local function clone_repo(url, dest, on_complete)
  if vim.fn.isdirectory(dest) == 1 then
    if on_complete then on_complete() end
    return
  end

  local name = vim.fn.fnamemodify(dest, ":t")
  dbg.log('bootstrap', 'cloning ' .. name)
  vim.notify(string.format("Cloning %s...", name), vim.log.levels.INFO)

  vim.fn.jobstart(
    { "git", "clone", "--depth", "1", url, dest },
    {
      on_exit = function(_, exit_code)
        vim.schedule(function()
          if exit_code == 0 then
            dbg.log('bootstrap', 'cloned ' .. name .. ' (exit=0)')
            vim.notify(string.format("Cloned %s", name), vim.log.levels.INFO)
          else
            dbg.log('bootstrap', 'failed to clone ' .. name .. ' (exit=' .. exit_code .. ')', vim.log.levels.ERROR)
            vim.notify(string.format("Failed to clone %s", name), vim.log.levels.ERROR)
          end
          if on_complete then on_complete() end
        end)
      end,
    }
  )
end

--- すべてのリポジトリを順番にクローン → 完了後に denops を手動起動
local function clone_all(index)
  if index > #utils.repos then
    dbg.log('bootstrap', 'all ' .. #utils.repos .. ' repos cloned')
    vim.notify("All repositories cloned!", vim.log.levels.INFO)

    -- クローン完了後に runtimepath に追加
    utils.prepend_repos_to_rtp()

    -- denops を手動起動 → DenopsReady が発火し通常フローに合流
    dbg.log('bootstrap', 'starting denops')
    vim.notify("Starting denops...", vim.log.levels.INFO)
    vim.cmd('runtime! plugin/denops.vim')
    return
  end

  local repo = utils.repos[index]
  clone_repo(repo.url, repo.path, function()
    clone_all(index + 1)
  end)
end

--- 未クローンのリポジトリがあればクローンを開始
---@return boolean needs_clone クローンが必要だったか
function M.ensure_repos()
  if vim.fn.executable("git") == 0 then
    return false
  end

  local needs_clone = false
  for _, repo in ipairs(utils.repos) do
    if vim.fn.isdirectory(repo.path) == 0 then
      needs_clone = true
      break
    end
  end

  if needs_clone then
    dbg.log('bootstrap', 'starting clone_all (' .. #utils.repos .. ' repos)')
    clone_all(1)
  else
    dbg.log('bootstrap', 'all repos already present')
  end

  return needs_clone
end

return M
