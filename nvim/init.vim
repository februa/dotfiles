" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

if has('python3') && has('win64')
    let g:python3_host_prog = expand('$HOME\AppData\Local\Programs\Python\Python37\python.exe')
endif
" ホームディレクトリとカウントディレクトリに.vimrc.localがあれば読み込む
augroup vimrc-local
  autocmd!
  autocmd VimEnter * call s:vimrc_local(expand('~/.vimrc.local'))
  autocmd BufNewFile,BufReadPost * call s:vimrc_local(expand('<afile>:p:h'))
augroup END

function! s:vimrc_local(loc)
  let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction

" ENV
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
function! s:load(file) abort
    let s:path = expand('$CONFIG/nvim/rc/' . a:file . '.vim')
    if filereadable(s:path)
        execute 'source' fnameescape(s:path)
    endif
endfunction
call s:load('fold')
call s:load('highlight')
call s:load('keymap')
call s:load('mouse')
call s:load('plugins')
call s:load('terminal')
call s:load('editor')
call s:load('encodings')
