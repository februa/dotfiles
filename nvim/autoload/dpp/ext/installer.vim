" DppInstall/DppUpdate 進捗表示
" dpp-ext-installer の autoload 関数を再定義する
"
" UI モード:
"   fidget — fidget.nvim の progress handle で表示（通常起動後）
"   split  — 画面下スプリットウィンドウで表示（初回インストール時等）
"
" 設計:
"   1. fidget.nvim の hook_source 完了時に _G._dpp_fidget_ready = true がセットされる
"   2. 進捗表示の開始時に UI モードを決定し、セッション中はロックする
"   3. close 時にロックを解放し、次のセッションで再判定可能にする
"
" 注意: _call_hook は実行中に再 source される可能性があるため
" ここでは再定義しない（元の dpp-ext-installer の実装をそのまま使う）

" --- Lua ヘルパー ---
if !exists('s:dpp_fidget_lua_loaded')
  let s:dpp_fidget_lua_loaded = 1
lua <<EOF
-- fidget progress handle（fidget モード時に使用）
local _dpp_handle = nil

-- UI モードロック: 'fidget' | 'split' | nil（未決定）
-- 進捗セッション開始時に決定し、close まで維持する
local _ui_mode = nil

--- fidget progress handle でメッセージを表示
function _G._dpp_fidget_progress(msg)
  local ok, handle_mod = pcall(require, 'fidget.progress.handle')
  if not ok then return end

  for line in msg:gmatch('[^\n]+') do
    local idx, total, name = line:match('^%[(%d+)/(%d+)%]%s+(.+)')
    if idx then
      local pct = math.floor(tonumber(idx) / tonumber(total) * 100)
      if not _dpp_handle or _dpp_handle.done then
        _dpp_handle = handle_mod.create({
          title = 'dpp',
          lsp_client = { name = 'dpp' },
          percentage = 0,
        })
      end
      _dpp_handle:report({
        message = name,
        percentage = pct,
      })
      if tonumber(idx) == tonumber(total) then
        _dpp_handle:finish()
        _dpp_handle = nil
      end
    end
  end
end

--- fidget progress handle を閉じる
function _G._dpp_fidget_close()
  if _dpp_handle and not _dpp_handle.done then
    _dpp_handle:finish()
  end
  _dpp_handle = nil
end

--- 進捗セッションの UI モードを決定・取得
--- 初回呼び出しで _G._dpp_fidget_ready に基づきモードを決定しロックする。
--- 以降はロック済みのモードを返す（セッション中に経路が切り替わらない）。
function _G._dpp_progress_mode()
  if _ui_mode then return _ui_mode end
  _ui_mode = _G._dpp_fidget_ready and 'fidget' or 'split'
  return _ui_mode
end

--- UI モードロックを解放（close 時に呼ぶ）
function _G._dpp_progress_reset()
  _ui_mode = nil
end
EOF
endif

" --- スプリットウィンドウ UI（split モード時に使用） ---
" 再 source 時にリセットしない（進行中のウィンドウ参照が失われ残骸になる）
if !exists('s:dpp_installer_winid')
  let s:dpp_installer_bufnr = -1
  let s:dpp_installer_winid = -1
endif

function! dpp#ext#installer#_print_progress_message(msg) abort
  " headless mode ではデフォルト動作（echomsg）
  if (has('nvim') && nvim_list_uis()->empty())
    echomsg '[dpp] ' .. a:msg
    return
  endif

  let l:mode = luaeval('_dpp_progress_mode()')

  if l:mode ==# 'fidget'
    call v:lua._dpp_fidget_progress(a:msg)
    return
  endif

  " split モード: スプリットウィンドウ UI
  if s:dpp_installer_winid <= 0 || win_id2win(s:dpp_installer_winid) == 0
    let s:dpp_installer_bufnr = nvim_create_buf(v:false, v:true)
    call setbufvar(s:dpp_installer_bufnr, '&buftype', 'nofile')
    call setbufvar(s:dpp_installer_bufnr, '&bufhidden', 'wipe')
    call setbufvar(s:dpp_installer_bufnr, '&swapfile', 0)
    call setbufvar(s:dpp_installer_bufnr, '&buflisted', 0)
    let save_winid = win_getid()
    execute 'botright sbuffer ' .. s:dpp_installer_bufnr
    resize 8
    setlocal winfixheight
    setlocal nonumber norelativenumber signcolumn=no
    let s:dpp_installer_winid = win_getid()
    call win_gotoid(save_winid)
  endif

  let lines = split(a:msg, '\n')
  for line in lines
    if line =~# '^\[\d\+/\d\+\]'
      " ヘッダー行 [index/total] plugin_name → 新しい行として追加
      if getbufline(s:dpp_installer_bufnr, 1) ==# ['']
        call setbufline(s:dpp_installer_bufnr, 1, line)
      else
        call appendbufline(s:dpp_installer_bufnr, '$', line)
      endif
    endif
  endfor

  " 自動スクロール
  if win_id2win(s:dpp_installer_winid) > 0
    call win_execute(s:dpp_installer_winid, "normal! G")
    redraw
  endif
endfunction

function! dpp#ext#installer#_close_progress_window() abort
  " ロック済みモードに基づいて閉じる（open と close の経路が必ず一致する）
  let l:mode = luaeval('_dpp_progress_mode()')

  if l:mode ==# 'fidget'
    call v:lua._dpp_fidget_close()
  else
    if s:dpp_installer_winid > 0 && win_id2win(s:dpp_installer_winid) > 0
      call nvim_win_close(s:dpp_installer_winid, v:true)
    endif
    let s:dpp_installer_winid = -1
    let s:dpp_installer_bufnr = -1
  endif

  " セッション終了: モードロックを解放（次回 open 時に再判定）
  call v:lua._dpp_progress_reset()
endfunction

function! dpp#ext#installer#_print_message(msg) abort
  const detect_shell = s:is_headless_mode()

  for mes in s:msg2list(a:msg)
    echomsg '[dpp] ' .. mes

    if has('nvim') && detect_shell
      echo "\n"
    endif
  endfor

  if !has('nvim') && detect_shell
    echo ""
  endif
endfunction

function! s:msg2list(expr) abort
  return a:expr->type() ==# v:t_list ? a:expr : a:expr->split('\n')
endfunction

function! s:is_headless_mode() abort
  return (has('nvim') && nvim_list_uis()->empty())
          \ || (!has('nvim') && mode(v:true) ==# 'ce')
endfunction

" ディレクトリ移動ヘルパー
function! s:cd(path) abort
  if !(a:path->isdirectory())
    return
  endif

  try
    noautocmd execute (haslocaldir() ? 'lcd' : 'cd') a:path->fnameescape()
  catch
    call dpp#util#_error('Error cd to: ' .. a:path)
    call dpp#util#_error('Current directory: ' .. getcwd())
    call dpp#util#_error(v:exception)
    call dpp#util#_error(v:throwpoint)
  endtry
endfunction

" _call_hook: 実行中に再 source されると E127 になるため、
" 既に定義済みの場合はスキップして元の定義を維持する
if !exists('*dpp#ext#installer#_call_hook')
  function! dpp#ext#installer#_call_hook(hook_name, plugin) abort
    " 初回インストール時は .dpp/lua/ 未構築 & 依存プラグイン未 clone のため
    " dpp#source() や hook 実行でエラーが発生する。
    " エラーを握りつぶしてインストーラーを続行させ、
    " 2回目の make_state + dpp_reload() で正しくセットアップする。
    try
      call dpp#source(a:plugin.name)
    catch
      " インストール中のソースエラーは無視（再構築後に再実行される）
    endtry

    const cwd = getcwd()
    try
      call s:cd(a:plugin.path)
      call dpp#util#_call_hook(a:hook_name, a:plugin.name)
    catch
      " hook エラーも無視（再構築後に再実行される）
    finally
      call s:cd(cwd)
    endtry
  endfunction
endif
