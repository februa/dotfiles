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
tnoremap <ESC> <C-\><C-n>
nnoremap <Up> gk
nnoremap <Down> gj

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
nmap sq :q<CR>
