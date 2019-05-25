set gdefault
set hidden  " allow buffer switching without saving
" (ubuntu) sudo apt-get install xsel
set clipboard+=unnamedplus
set undofile
set swapfile
set autowriteall
set completeopt=menu,preview,noinsert
" Auto-close quickfix window
autocmd MyAutoCmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif

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

" set inccommand=split

" Edit:
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
set showtabline=2  " always show tabline
