if has('win64')
    set shell=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
    set shellcmdflag=-NoLogo\ -Command
    set shellquote=\"
    set shellxquote=
    source $VIMRUNTIME/mswin.vim
elseif has('unix')
    set shell=/bin/bash
endif

" Open terminal on new buffer
autocmd MyAutoCmd VimEnter * if @% == '' && s:GetBufByte() == 0 | call Term()
function! s:GetBufByte()
  let byte = line2byte(line('$') + 1)
  if byte == -1
    return 0
  else
    return byte - 1
  endif
endfunction

function! Term()
  call termopen(&shell, {'on_exit': 'OnExit'})
endfunction

function! OnExit(job_id, code, event)
  if a:code == 0
    call CloseBuf()
  endif
endfunction

function! CloseBuf()
  if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1 || winnr('$') > 1
    :q
  elseif &buftype == 'terminal'
    :bd!
  else
    :bd
  endif
endfunction
nnoremap :q<CR> :up<CR>:call CloseBuf()<CR>
cnoremap  q<CR> :up<CR>:call CloseBuf()<CR>
