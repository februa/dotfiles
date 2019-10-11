if has('win64')
    set shell=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
    set shellcmdflag=-NoLogo\ -Command
    set shellquote=\"
    set shellxquote=
    source $VIMRUNTIME/mswin.vim
elseif has('unix')
    set shell=/usr/bin/fish
endif

" Open terminal on new buffer
autocmd MyAutoCmd VimEnter * if @% == '' && s:GetBufByte() == 0 | call Term()
function! s:GetBufByte()
  let l:byte = line2byte(line('$') + 1)
  if l:byte == -1
    return 0
  else
    return l:byte - 1
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

let s:noloaded_closecmddict = {
            \'help': 'helpclose',
            \'tagbar' : 'TagbarClose',
            \'nerdtree' : 'NERDTreeClose',
            \'undotree' : 'UndotreeHide',
            \'denite' : 'quit',
            \'denite-filter' : 'quit',
            \}

function! CloseBuf()
  let l:bufcount = len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
  let l:tabcount = len(range(1, tabpagenr('$')))
  let l:noloaded_buflist = filter(tabpagebuflist(), '!buflisted(v:val)')

  if (l:bufcount == 1 || winnr('$') > 1) && len(l:noloaded_buflist) == 0
    :q
  elseif len(l:noloaded_buflist) > 0
      for [ft, cmd] in items(s:noloaded_closecmddict)
        if &filetype == ft
          :execute cmd
        endif
      endfor
  elseif &filetype == 'qf'
    :ccl
    :lcl
  elseif l:tabcount > 1 && winnr('$') == 1
    :tabclose
  elseif &buftype == 'terminal'
    :bd!
  else
    :bd
  endif
endfunction
nnoremap :q<CR> :call CloseBuf()<CR>
cnoremap q<CR> :call CloseBuf()<CR>
