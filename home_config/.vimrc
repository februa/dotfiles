if &compatible
    set nocompatible
endif

" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

" Visual: {{{
set autoread
set showcmd
" Statusline: {{{
" ファイル名表示
set statusline=%F
" 変更チェック表示
set statusline+=%m
" 読み込み専用かどうか表示
set statusline+=%r
" ヘルプページなら[HELP]と表示
set statusline+=%h
" プレビューウインドウなら[Prevew]と表示
set statusline+=%w
" これ以降は右寄せ表示
set statusline+=%=
" filetype
set statusline+=[%{&filetype}]
" file encoding
set statusline+=[%{&fileencoding}]
" file format
set statusline+=[%{&fileformat}]
" 現在行数/全行数
set statusline+=[%l/%L]
" ステータスラインを常に表示(0:表示しない、1:2つ以上ウィンドウがある時だけ表示)
set laststatus=2
" }}}
" (ubuntu) sudo apt-get install xsel
set clipboard+=unnamedplus
set backspace=indent,eol,start
" コマンドラインの補完
set wildmode=list:longest
set display=lastline
" }}}
" Vimfiles: {{{
set undofile 
set swapfile
set backup
" backupfile option
set backupext=.backup
" swapfile options
set updatetime=30000  "30秒ごとに保存
set updatecount=500   "500文字タイプするごとに保存
" 保存場所の自動作成
set undodir=~/.vim/undo
set directory=~/.vim/swap
set backupdir=~/.vim/backup
if !isdirectory(&undodir)
    call mkdir(iconv(&undodir,   &encoding, &termencoding), 'p')
    call mkdir(iconv(&directory, &encoding, &termencoding), 'p')
    call mkdir(iconv(&backupdir, &encoding, &termencoding), 'p')
endif
" ファイルを開いた際にディレクトリを作るかどうか聞かれる
augroup vimrc-auto-mkdir  " {{{
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)  " {{{
    if !isdirectory(a:dir) && (a:force ||
    \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction  " }}}
augroup END  " }}}
" }}}
" Edit: {{{
" Smart insert tab setting.
set smarttab
" Exchange tab to spaces.
set expandtab
" Substitute <Tab> with blanks.
set tabstop=4
" Spaces instead <Tab>.
set softtabstop=0
" Autoindent width.
set shiftwidth=4
" Round indent by shiftwidth.
set shiftround
" Enable smart indent.
set autoindent smartindent

set virtualedit=block

" }}}
" Fold: {{{
set foldenable
autocmd MyAutoCmd FileType vim,toml,dockerfile setlocal foldmethod=marker
autocmd MyAutoCmd FileType text setlocal foldmethod=indent
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
" Encode: {{{
set fileformats=mac,unix,dos
set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8
" }}}
" Mouse: {{{
" n	ノーマルモード
" v	ビジュアルモード
" i	挿入モード
" c	コマンドラインモード
" h	ヘルプファイルを閲覧しているときの上記のモード全て
" a	上記のモード全て
" r	hit-enter プロンプトが出ているとき
set mouse=nvcr
set nomousefocus
set mousehide
" }}}
" Keymapping: {{{
" :map   :noremap  :unmap     ノーマル、ビジュアル、選択、オペレータ待機
" :nmap  :nnoremap :nunmap    ノーマル
" :vmap  :vnoremap :vunmap    ビジュアル、選択
" :smap  :snoremap :sunmap    選択
" :xmap  :xnoremap :xunmap    ビジュアル
" :omap  :onoremap :ounmap    オペレータ待機
" :map!  :noremap! :unmap!    挿入、コマンドライン
" :imap  :inoremap :iunmap    挿入
" :lmap  :lnoremap :lunmap    挿入、コマンドライン、Lang-Arg
" :cmap  :cnoremap :cunmap    コマンドライン
" :tmap  :tnoremap :tunmap    端末ジョブ

let mapleader = "\\"
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nmap <Up> k
nmap <Down> j
vmap <Up> k
vmap <Down> j

nnoremap Y y$
nnoremap Q gq
nnoremap j gj
nnoremap k gk

" Visual mode keymappings:
" Indent
nnoremap > >>
nnoremap < <<
xnoremap > >gv
xnoremap < <gv
" Disable ZZ.
nnoremap ZZ  <Nop>
" Easy escape.
inoremap jj  <ESC>
cnoremap <expr> j
      \ getcmdline()[getcmdpos()-2] ==# 'j' ? "\<BS>\<C-c>" : 'j'
" }}}
" Search: {{{
" Highlight <>.
set matchpairs+=<:>
" Ignore the case of normal letters.
set ignorecase
" If the search pattern contains upper case characters, override ignorecase
" option.
set smartcase
" Enable incremental search.
set incsearch
" Searches wrap around the end of the file.
set wrapscan
" 検索語をハイライト表示しない(ハイライトしたい場合noを消して)
set nohlsearch
" ESC連打でハイライト解除
" nmap <Esc><Esc> :nohlsearch<CR><Esc>
" }}}
" Plugins: {{{
" s:load_plugin (1:enable 0:not enable)
let s:load_plugin = 1
" plugins config functions {{{

function s:caw_config()
    " {{{
    " 行の最初の文字の前にコメント文字をトグル
    nmap <Leader>, <Plug>(caw:hatpos:toggle)
    vmap <Leader>, <Plug>(caw:hatpos:toggle)
    " 行頭にコメントをトグル
    nmap <Leader>c <Plug>(caw:zeropos:toggle)
    vmap <Leader>c <Plug>(caw:zeropos:toggle)
    " }}}
endfunction

function s:undotree_config() 
    " {{{
    let g:undotree_WindowLayout = 2         " undotreeは左側/diffは下にウィンドウ幅で表示
    let g:undotree_ShortIndicators = 1      " 時間単位は短く表示
    let g:undotree_SplitWidth = 30          " undotreeのウィンドウ幅
    let g:undotree_SetFocusWhenToggle = 1   " undotreeを開いたらフォーカスする
    let g:undotree_DiffpanelHeight = 8      " diffウィンドウの行数
    let g:undotree_HighlightChangedText = 1 " 変更箇所のハイライト
    " undotreeをトグル表示
    noremap <C-u> :UndotreeToggle<CR>

    " undotreeバッファ内でのキーバインド設定
    function! g:Undotree_CustomMap()
        map <silent> <buffer> <Esc> q
        map <silent> <buffer> h ?
    endfunction
    "}}}
endfunction

function s:nerdtree_config()
    " {{{
    let g:NERDTreeShowBookmarks=1
    let g:NERDTreeShowHidden=1
    let g:NERDTreeQuitOnOpen=1
    let g:NERDTreeMouseMode=2
    let g:NERDTreeDirArrows=0
    let g:NERDTreeIgnore=['\.git$', '\.clean$', '\.swp$', '\.bak$', '\~$']
    let g:NERDTreeBookmarksFile=''
    " nerdtreeをトグル表示
    nnoremap <C-n> :NERDTreeToggle<CR>
    " }}}
endfunction

function s:acceljk_config()
    " {{{
    " j,kにキーマッピング
    nmap j <Plug>(accelerated_jk_gj)
    nmap k <Plug>(accelerated_jk_gk)
    " }}}
endfunction

function s:solarized8_config()
    let g:solarized_diffmode = 'normal'
    let g:solarized_enable_extra_hi_groups = 1
    let g:solarized_visibility = 'normal'
    let g:solarized_term_italics = 1
endfunction
" }}}
if s:load_plugin && executable('git')
    let s:dein_dir = expand('$HOME/.vim/dein')
    let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
    let g:dein#install_max_processes = 8
    let g:dein#install_message_type = 'echo'

    if &runtimepath !~# '/dein.vim'
    if !isdirectory(s:dein_repo_dir)
        execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    endif
    execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
    endif

    let g:dein#install_progress_type = 'tabline'
    let g:dein#enable_notification = 1

    if dein#load_state(s:dein_dir)
        call dein#begin(s:dein_dir)
        

        " Required
        call dein#add('Shougo/dein.vim')

        " add plugins
        call dein#add('Shougo/vimproc.vim', {'build' : 'make' })
        call dein#add('mbbill/undotree')
        call dein#add('scrooloose/nerdtree')
        call dein#add('tpope/vim-surround')
        call dein#add('vim-jp/vimdoc-ja')
        call dein#add('tyru/caw.vim')
        call dein#add('rhysd/accelerated-jk')
        call dein#add('delphinus/vim-auto-cursorline')
        call dein#add('Townk/vim-autoclose')
        call dein#add('haya14busa/is.vim')
        call dein#add('kana/vim-textobj-user')
        call dein#add('machakann/vim-highlightedyank')
        call dein#add('itchyny/vim-cursorword')
        call dein#add('tpope/vim-endwise')
        call dein#add('Yggdroot/indentLine')

        " filetype syntax plugins
        call dein#add('Vimjas/vim-python-pep8-indent')
        call dein#add('ekalinin/Dockerfile.vim')
        call dein#add('vim-jp/syntax-vim-ex')

        " colorscheme
        call dein#add('lifepillar/vim-solarized8')
        call dein#add('sickill/vim-monokai')
        call dein#add('flazz/vim-colorschemes')

        " plugins config
        " call dein#config('indentLine', {'on_ft' : ['python']})

        " hooked plugins options
        call dein#set_hook('caw.vim', 'hook_add',  function('s:caw_config'))
        call dein#set_hook('undotree', 'hook_add', function('s:undotree_config'))
        call dein#set_hook('nerdtree', 'hook_add', function('s:nerdtree_config'))
        call dein#set_hook('accelerated-jk', 'hook_add', function('s:acceljk_config'))
        call dein#set_hook('vim-solarized8', 'hook_add', function('s:solarized8_config'))

        call dein#end()
        call dein#save_state()
    endif

    if dein#check_install()
        call dein#install()
    endif

    " set colorscheme
    " colorscheme 設定は source 後に行う必要があるので VimEnter で行う。
    " 但し Colorscheme イベントの発生が抑制されないよう nented を付ける。
    autocmd MyAutoCmd vimenter * nested colorscheme solarized8_high

endif

syntax enable
filetype plugin indent on
" }}}
set background=dark
