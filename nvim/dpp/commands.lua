-- dpp ユーザーコマンド定義
local utils = require('dpp.utils')
local dbg = require('config.debug')
local M = {}

--- state再構築用の共通関数
local function dpp_make_state()
  local reload = require('dpp.reload')
  dbg.log('dpp-cmd', 'dpp_make_state invoked')
  vim.notify("Rebuilding dpp state...", vim.log.levels.INFO)
  local completed = false
  vim.api.nvim_create_autocmd("User", {
    pattern = "Dpp:makeStatePost",
    callback = function()
      completed = true
      dbg.log('dpp-cmd', 'dpp_make_state: Dpp:makeStatePost received → dpp_reload')
      reload.dpp_reload()
    end,
    once = true,
  })
  vim.fn["dpp#make_state"](utils.dpp_base, utils.dpp_config_path)
  -- 60秒後にタイムアウト検知
  vim.defer_fn(function()
    if not completed then
      dbg.log('dpp-cmd', 'dpp_make_state: timeout (60s)', vim.log.levels.ERROR)
      vim.notify("dpp#make_state timeout! Check :messages for denops errors", vim.log.levels.ERROR)
    end
  end, 60000)
end

--- DenopsReady 後にユーザーコマンドを登録
function M.register()
  -- :DppMakeState — TOML変更を反映するためstateを再構築
  vim.api.nvim_create_user_command("DppMakeState", function()
    dpp_make_state()
  end, { desc = "Rebuild dpp state from TOML config" })

  -- :DppInstall — state再構築 → インストール → state再構築 → リロード
  vim.api.nvim_create_user_command("DppInstall", function()
    local reload = require('dpp.reload')
    dbg.log('dpp-cmd', ':DppInstall invoked')
    vim.notify("Rebuilding state and installing plugins...", vim.log.levels.INFO)
    local completed = false
    vim.api.nvim_create_autocmd("User", {
      pattern = "Dpp:makeStatePost",
      callback = function()
        completed = true
        if vim.loader and vim.loader.reset then
          vim.loader.reset()
        end
        vim.fn["dpp#min#load_state"](utils.dpp_base)

        dbg.log('dpp-cmd', ':DppInstall: make_state done, starting install')
        -- installer 完了後に state を再構築（clone 後のプラグインを .dpp にマージ）
        vim.api.nvim_create_autocmd("User", {
          pattern = "Dpp:ext:installer:updateDone",
          callback = function()
            dbg.log('dpp-cmd', ':DppInstall: install done, rebuilding state')
            vim.notify("Install done. Rebuilding state with all plugins...", vim.log.levels.INFO)
            if vim.loader and vim.loader.reset then
              vim.loader.reset()
            end
            vim.api.nvim_create_autocmd("User", {
              pattern = "Dpp:makeStatePost",
              callback = function()
                dbg.log('dpp-cmd', ':DppInstall: post-install make_state done → dpp_reload')
                reload.dpp_reload()
              end,
              once = true,
            })
            vim.fn["dpp#make_state"](utils.dpp_base, utils.dpp_config_path)
          end,
          once = true,
        })

        vim.cmd("call dpp#async_ext_action('installer', 'install')")
      end,
      once = true,
    })
    vim.fn["dpp#make_state"](utils.dpp_base, utils.dpp_config_path)
    vim.defer_fn(function()
      if not completed then
        dbg.log('dpp-cmd', ':DppInstall: make_state timeout (60s)', vim.log.levels.ERROR)
        vim.notify("DppInstall: make_state timeout! Check :messages for denops errors", vim.log.levels.ERROR)
      end
    end, 60000)
  end, { desc = "Rebuild state then install new plugins" })

  -- :DppUpdate — プラグインを更新 → state再構築 → リロード
  vim.api.nvim_create_user_command("DppUpdate", function()
    local reload = require('dpp.reload')
    dbg.log('dpp-cmd', ':DppUpdate invoked')
    vim.notify("Updating plugins...", vim.log.levels.INFO)
    vim.api.nvim_create_autocmd("User", {
      pattern = "Dpp:ext:installer:updateDone",
      callback = function()
        dbg.log('dpp-cmd', ':DppUpdate: update done, rebuilding state')
        vim.notify("Update done. Rebuilding state...", vim.log.levels.INFO)
        if vim.loader and vim.loader.reset then
          vim.loader.reset()
        end
        vim.api.nvim_create_autocmd("User", {
          pattern = "Dpp:makeStatePost",
          callback = function()
            reload.dpp_reload()
          end,
          once = true,
        })
        vim.fn["dpp#make_state"](utils.dpp_base, utils.dpp_config_path)
      end,
      once = true,
    })
    vim.cmd("call dpp#async_ext_action('installer', 'update')")
  end, { desc = "Update installed plugins" })

  -- :DppClearCache — Lua/dpp キャッシュをクリアして state を再構築
  vim.api.nvim_create_user_command("DppClearCache", function()
    local reload = require('dpp.reload')
    dbg.log('dpp-cmd', ':DppClearCache invoked')
    vim.notify("Clearing caches...", vim.log.levels.INFO)
    if vim.loader and vim.loader.reset then
      vim.loader.reset()
    end
    local state_dir = utils.dpp_base .. "/nvim/.dpp"
    if vim.fn.isdirectory(state_dir) == 1 then
      vim.fn.delete(state_dir, "rf")
      vim.notify("Deleted: " .. state_dir, vim.log.levels.INFO)
    end
    vim.api.nvim_create_autocmd("User", {
      pattern = "Dpp:makeStatePost",
      callback = function()
        if vim.loader and vim.loader.reset then
          vim.loader.reset()
        end
        for name in pairs(package.loaded) do
          if name:match('^plugins%.') or name:match('^which%-key') then
            package.loaded[name] = nil
          end
        end
        reload.dpp_reload()
      end,
      once = true,
    })
    vim.fn["dpp#make_state"](utils.dpp_base, utils.dpp_config_path)
  end, { desc = "Clear all caches and rebuild dpp state" })

  -- :DppClean — TOML から削除されたプラグインのディレクトリを検出・削除
  vim.api.nvim_create_user_command("DppClean", function()
    dbg.log('dpp-cmd', ':DppClean invoked')
    vim.api.nvim_create_autocmd("User", {
      pattern = "Dpp:makeStatePost",
      callback = function()
        if vim.loader and vim.loader.reset then
          vim.loader.reset()
        end
        vim.fn["dpp#min#load_state"](utils.dpp_base)
        vim.fn["dpp#source"]()
        local managed = vim.fn["dpp#get"]()
        local repos_dir = utils.dpp_base .. "/repos/github.com"

        -- 管理対象のパスを正規化して集合に格納
        local managed_paths = {}
        for _, plugin in pairs(managed) do
          if plugin.path then
            managed_paths[vim.fs.normalize(plugin.path)] = true
          end
        end

        -- init.lua の repos テーブルにある必須プラグインも保護
        for _, repo in ipairs(utils.repos) do
          managed_paths[vim.fs.normalize(repo.path)] = true
        end

        -- repos ディレクトリ内を走査して不要なものを検出
        local orphans = {}
        local ok, authors = pcall(vim.fn.readdir, repos_dir)
        if not ok then
          vim.notify("repos directory not found: " .. repos_dir, vim.log.levels.ERROR)
          return
        end
        for _, author in ipairs(authors) do
          local author_path = repos_dir .. "/" .. author
          if vim.fn.isdirectory(author_path) == 1 then
            local plugin_dirs = vim.fn.readdir(author_path)
            for _, pname in ipairs(plugin_dirs) do
              local full_path = vim.fs.normalize(author_path .. "/" .. pname)
              if not managed_paths[full_path] then
                table.insert(orphans, { name = author .. "/" .. pname, path = full_path })
              end
            end
          end
        end

        if #orphans == 0 then
          vim.notify("No orphan plugin directories found.", vim.log.levels.INFO)
          return
        end

        vim.notify("Orphan plugin directories:", vim.log.levels.WARN)
        for i, o in ipairs(orphans) do
          vim.notify(string.format("  %d. %s", i, o.name), vim.log.levels.WARN)
        end

        local answer = vim.fn.input("Delete these directories? [y/N]: ")
        print("")
        if answer:lower() == "y" then
          for _, o in ipairs(orphans) do
            vim.fn.delete(o.path, "rf")
            vim.notify("Deleted: " .. o.name, vim.log.levels.INFO)
          end
          vim.notify("Clean complete. Run :DppMakeState to refresh.", vim.log.levels.INFO)
        else
          vim.notify("Clean cancelled.", vim.log.levels.INFO)
        end
      end,
      once = true,
    })
    vim.fn["dpp#make_state"](utils.dpp_base, utils.dpp_config_path)
  end, { desc = "Remove plugin dirs not in TOML" })
end

--- dpp_make_state を公開（外部から呼べるように）
M.make_state = dpp_make_state

return M
