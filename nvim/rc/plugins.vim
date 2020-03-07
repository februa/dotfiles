scriptencoding utf-8

set shellslash

let s:dein_dir = expand('$CACHE/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
let g:dein#install_max_processes = 16
let g:dein#install_message_type = 'echo'
let g:dein#auto_recache = 0
let g:dein#install_progress_type = 'tabline'
let g:dein#enable_notification = 1
let g:dein#types#git#clone_depth = 1

if has('python3') && has('win64')
    let g:python3_host_prog = expand('$HOME/AppData/Local/Programs/Python/Python37/python.exe')
elseif has('python3') && has('unix')
    let g:python3_host_prog = expand('$HOME/.pyenv/shims/python3')
    let g:python_host_prog = expand('$HOME/.pyenv/shims/python')
endif

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  let s:toml = [
    \ {'name': 'default'},
    \ {'name': 'denite',   'lazy': 1},
    "\ {'name': 'vim-lsp'},
    \ {'name': 'deoplete', 'lazy': 1},
    \ {'name': 'lazy',     'lazy': 2},
    \ {'name': 'ftplugin'},
    \ ]
  let s:path = {name -> expand('$CONFIG/nvim/dein/' . name . '.toml')}
  let s:load_toml = {name, lazy -> dein#load_toml(s:path(name), {'lazy': lazy})}

  call dein#begin(s:dein_dir, map(deepcopy(s:toml), {_, t -> t['name']}))
  call map(s:toml, {_, t -> s:load_toml(t['name'], get(t, 'lazy', 0))})
  call dein#end()
  call dein#save_state()

endif

" ColorScheme:
autocmd MyAutoCmd vimenter * nested colorscheme solarized8_high


if dein#check_install()
  call dein#install()
endif
