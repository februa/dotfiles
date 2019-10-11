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

nnoremap s <C-w>

nnoremap <C-j> <C-w>w
nnoremap bn :<C-u>bNext<CR>
nnoremap bp :<C-u>bprevious<CR>
nnoremap bd :<C-u>bdelete<CR>
nnoremap ts :<C-u>tab split<CR>
nnoremap tn :<C-u>tabnext<CR>
nnoremap tp :<C-u>tabprevious<CR>
nnoremap tc :<C-u>tabclose<CR>
