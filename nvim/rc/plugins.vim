let s:dein_dir = expand('$DATA/dein')

if &runtimepath !~# '/dein.vim'
    let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
    " Auto Download
    if !isdirectory(s:dein_repo_dir)
        execute '!git clone https://github.com/Shougo/dein.vim ' . s:dein_repo_dir
    endif
    execute 'set runtimepath^=' . s:dein_repo_dir
endif
if has('python3') && has('win64')
    let g:python3_host_prog = expand('$HOME\AppData\Local\Programs\Python\Python37\python.exe')
elseif has('python3') && has('unix')
    let g:python3_host_prog = expand('/home/leberac/.pyenv/shims/python3')
    let g:python_host_prog = expand('/home/leberac/.pyenv/shims/python')
endif
let g:dein#install_max_processes = 16
let g:dein#install_message_type = 'none'

if !dein#load_state(s:dein_dir)
    finish
endif

function! s:load_plugin(file,num) abort
    let s:toml_path = expand('$CONFIG/nvim/dein/' . a:file . '.toml')
    if filereadable(s:toml_path)
        call dein#load_toml(s:toml_path,{'lazy': a:num})
    endif
endfunction

call dein#begin(s:dein_dir, expand('<sfile>'))

call s:load_plugin('plugins', 0)
call s:load_plugin('colors', 0)
call s:load_plugin('appearance', 0)
call s:load_plugin('denite', 1)
call s:load_plugin('ale', 1)
call s:load_plugin('filetype', 2)

if has('python3')
    call s:load_plugin('deoplete', 2)
    if has('unix')
        call s:load_plugin('vimtex', 2)
    endif
endif

call dein#end()
call dein#save_state()

if has('vim_starting') && dein#check_install()
    call dein#install()
endif
