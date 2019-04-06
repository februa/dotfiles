set encoding=utf-8
scriptencoding utf-8
if !&compatible
    set nocompatible
endif
" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END
syntax enable
" Enable backspace delete indent and newline.
set backspace=indent,eol,start
" When a line is long, do not omit it in @.
set display=lastline
set ttyfast
" vim plugin {{{
" dein自体の自動インストール {{{
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir .",". &runtimepath
" }}}
" プラグイン読み込み＆キャッシュ作成
" please type a command
" sudo add-apt-repository ppa:jonathonf/vim
let s:toml_file = fnamemodify(expand('<sfile>'), ':h').'/.dein.toml'
let s:lazy_toml = fnamemodify(expand('<sfile>'), ':h').'/.dein_lazy.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  if filereadable(s:toml_file)
    call dein#load_toml(s:toml_file, {'lazy':0})
  endif
  if filereadable(s:lazy_toml)
    call dein#load_toml(s:lazy_toml, {'lazy':1})
  endif
  call dein#end()
  call dein#save_state()
endif
" 不足プラグインの自動インストール
if has('vim_starting') && dein#check_install()
  call dein#install()
endif
" }}}
" 動作設定関連 {{{
set confirm
set autoread
set clipboard=unnamed,autoselect
" Display another buffer when current buffer isn't saved.
set hidden
let &directory=s:cache_home . "/vimfiles/swap"
let &backupdir=s:cache_home . "/vimfiles/backup"
let &undodir=s:cache_home . "/vimfiles/undo"
set backup
set undofile
set noswapfile
" }}}
" マウス設定  {{{
if has('mouse')
    set mouse=n
    if has('mouse_sgr')
        set ttymouse=sgr
    elseif v:version > 703 || v:version is 703 && has('patch632')
        set ttymouse=sgr
    else
        set ttymouse=xterm2
    endif
endif
set nomousefocus
set mousehide
" }}} 
" Edit: {{{
filetype plugin indent on
" Smart insert tab setting.
set smarttab
" Exchange tab to spaces.
"set expandtab
" Substitute <Tab> with blanks.
set tabstop=4
" Spaces instead <Tab>.
"set softtabstop=4
" Autoindent width.
set shiftwidth=4
" Round indent by shiftwidth.
set shiftround
" Enable smart indent.
set autoindent smartindent
" Highlight <>.
set matchpairs+=<:>
" }}}
" View: {{{
" Show line number.
"set number
" Show <TAB> and <CR>
set nolist
" Height of command line.
set cmdheight=1
" Not show command on statusline.
set noshowcmd
" Display candidate supplement.
set nowildmenu
set wildmode=list:longest,full
" Increase history amount.
set history=1000

set showmatch

set t_vb =
set novisualbell
set belloff=all
" }}}
" Search: {{{
" Ignore the case of normal letters.
set ignorecase
" If the search pattern contains upper case characters, override ignorecase
" option.
set smartcase
" Enable incremental search.
set incsearch
" Don't highlight search result.
set nohlsearch
" Searches wrap around the end of the file.
set wrapscan
set gdefault
" }}}
" Folding: {{{
" Enable folding.
set foldenable
au FileType vim,toml setlocal foldmethod=marker
au FileType text setlocal foldmethod=indent
" FastFold
autocmd MyAutoCmd TextChangedI,TextChanged *
      \ if &l:foldenable && &l:foldmethod !=# 'manual' |
      \   let b:foldmethod_save = &l:foldmethod |
      \   let &l:foldmethod = 'manual' |
      \ endif
autocmd MyAutoCmd BufWritePost *
      \ if &l:foldmethod ==# 'manual' && exists('b:foldmethod_save') |
      \   let &l:foldmethod = b:foldmethod_save |
      \   execute 'normal! zx' |
      \ endif
" }}}
" Key-mappings: {{{
nnoremap <Up> gk
nnoremap <Down> gj

nnoremap Y y$
nnoremap Q gq
nnoremap j gj
nnoremap k gk

let mapleader = "\<Space>"
" Useful save mappings.
nnoremap <silent> <Leader><Leader> :<C-u>update<CR>
" Visual mode keymappings:
" Indent
nnoremap > >>
nnoremap < <<
xnoremap > >gv
xnoremap < <gv
" Disable Ex-mode.
nnoremap Q  q
" Disable ZZ.
nnoremap ZZ  <Nop>
" Easy escape.
inoremap jj           <ESC>
cnoremap <expr> j
      \ getcmdline()[getcmdpos()-2] ==# 'j' ? "\<BS>\<C-c>" : 'j'
inoremap j<Space>    j

" }}}
augroup MyAutoCmd
  " Auto-close quickfix window
  autocmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif
augroup END 
