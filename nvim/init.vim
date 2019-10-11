" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

" Environment:
set fileformats=unix,dos,mac
set fileencodings=utf-8,iso-2022-jp,cp932,sjis,euc-jp
if     has('unix') || has('mac')
        let $CACHE = expand('$HOME/.cache')
        let $CONFIG = expand('$HOME/.config')
        let $DATA = expand('$HOME/.local/share')
elseif has('win32')
        let $CACHE = expand('$HOME/AppData/Local/nvim-data/cache')
        let $CONFIG = expand('$HOME/AppData/Local')
        let $DATA = expand('$HOME/AppData/Local/nvim-data')
endif

" Load rc file
let s:rc = [
  \ 'keymap',
  \ 'editor',
  \ 'plugins',
  \ 'terminal',
  \ ]
let s:path = {name -> expand('$CONFIG/nvim/rc/' . name . '.vim')}
let s:load_rc = {file -> execute('source ' . fnameescape(file))}
call map(s:rc, {_, t -> s:load_rc( s:path(t) )})
