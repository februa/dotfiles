if has('win64')
    set shell=cmd.exe
    set shellcmdflag=-NoProfile\ -NoLogo\ -NonInteractive\ -Command
endif


" Open terminal on new buffer
autocmd VimEnter * if @% == '' && s:GetBufByte() == 0 | call Term()
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

function! CloseLastTerm()
  if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    :q
  endif
endfunction

function! OnExit(job_id, code, event)
  if a:code == 0
    call CloseLastTerm()
  endif
endfunction
function! CloseBuf()
  if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    :q
  else
    :bd
  endif
endfunction

nnoremap <Leader>q :up<CR>:call CloseBuf()<CR>
