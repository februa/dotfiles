-- デバッグトレース
-- vim.g.debug_mode = true で有効化（init.lua で設定）
-- fidget.nvim を迂回し :messages に直接書き込む
-- 用途: dpp ライフサイクル（bootstrap → make_state → install → reload）の追跡

local M = {}

--- デバッグモードが有効か
---@return boolean
function M.enabled()
  return vim.g.debug_mode == true
end

--- デバッグトレース出力（debug_mode 時のみ）
--- nvim_echo で :messages に直接書き込む（fidget.nvim を回避）
---@param category string  "dpp", "bootstrap", "reload", "safe" 等
---@param msg string
---@param level? integer vim.log.levels.* (デフォルト: DEBUG)
function M.log(category, msg, level)
  if not M.enabled() then return end
  level = level or vim.log.levels.DEBUG
  local hl = 'Comment'
  if level == vim.log.levels.WARN then
    hl = 'WarningMsg'
  elseif level == vim.log.levels.ERROR then
    hl = 'ErrorMsg'
  elseif level == vim.log.levels.INFO then
    hl = 'Normal'
  end
  local timestamp = vim.fn.strftime('%H:%M:%S')
  vim.api.nvim_echo({{ string.format('[%s][%s] %s', timestamp, category, msg), hl }}, true, {})
end

return M
