if &compatible
  set nocompatible
endif

" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

" ENV
if     has('unix') || has('mac')
        let $CACHE = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
        let $CONFIG = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME
        let $DATA = empty($XDG_DATA_HOME) ? expand('$HOME/.local/share') : $XDG_DATA_HOME
elseif has('win32')
        let $CACHE = expand('$HOME/AppData/Local/nvim-data/cache')
        let $CONFIG = expand('$HOME/AppData/Local')
        let $DATA = expand('$HOME/AppData/Local/nvim-data')
endif
" Load rc file
function! s:load(file) abort
    let s:path = expand('$CONFIG/nvim/rc/' . a:file . '.vim')
    if filereadable(s:path)
        execute 'source' fnameescape(s:path)
    endif
endfunction
call s:load('fold')
call s:load('keymap')
call s:load('mouse')
call s:load('plugins')
call s:load('terminal')
call s:load('editor')
call s:load('ime')
