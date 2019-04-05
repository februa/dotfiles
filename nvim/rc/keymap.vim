let mapleader = "\<Space>"

noremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
tnoremap <ESC> <C-\><C-n>
nnoremap <Up> gk
nnoremap <Down> gj

nnoremap Y y$
nnoremap Q gq
nnoremap j gj
nnoremap k gk

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
inoremap jj  <ESC>
cnoremap <expr> j
      \ getcmdline()[getcmdpos()-2] ==# 'j' ? "\<BS>\<C-c>" : 'j'
inoremap j<Space>    j

nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sn :<C-u>bn<CR>
nnoremap sp :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sQ :<C-u>bd<CR>
