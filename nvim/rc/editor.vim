set gdefault
set hidden  " allow buffer switching without saving
" (ubuntu) sudo apt-get install xsel
set clipboard+=unnamedplus
set undofile
set swapfile
set autowriteall

" Search:
" Highlight <>.
set matchpairs+=<:>
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
set shortmess+=s

" Edit:
" Smart insert tab setting.
set smarttab
" Exchange tab to spaces.
set expandtab
" Substitute <Tab> with blanks.
set tabstop=2
" Spaces instead <Tab>.
set softtabstop=0
" Autoindent width.
set shiftwidth=2
" Round indent by shiftwidth.
set shiftround
" Enable smart indent.
set autoindent smartindent
set showtabline=2  " always show tabline

" Fold:
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

" Mouse:
set mouse=nv
set nomousefocus
set mousehide
