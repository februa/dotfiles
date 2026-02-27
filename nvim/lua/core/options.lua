-- 基本オプション設定（プラグイン非依存）

-- Shell {{{
if vim.fn.executable('pwsh') == 1 then
  vim.opt.shell = 'pwsh'
  vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.opt.shellquote = ''
  vim.opt.shellxquote = ''
end
-- }}}

-- Editor {{{
vim.opt.title = true                      -- ウィンドウタイトルを変更
vim.opt.inccommand = "split"              -- 置換プレビューを分割ウィンドウで表示
vim.opt.shortmess:append("c")             -- 補完メッセージを短縮
vim.opt.formatoptions:append("mM")        -- 日本語の整形を改善

vim.opt.expandtab = true                  -- タブをスペースに展開
vim.opt.tabstop = 4                       -- タブ文字の表示幅
vim.opt.shiftwidth = 4                    -- 自動インデントの幅
vim.opt.softtabstop = 4                   -- タブキー押下時の挿入幅

vim.opt.splitbelow = true                 -- 水平分割時は下に開く
vim.opt.splitright = true                 -- 垂直分割時は右に開く
vim.opt.splitkeep = "screen"              -- 分割時にカーソル位置を維持

vim.opt.scrolloff = 8                     -- カーソルの上下に常に8行の余白を保つ
vim.opt.sidescrolloff = 8                 -- カーソルの左右に常に8列の余白を保つ

vim.opt.completeopt = "menu,menuone,noselect"  -- 補完メニューの挙動
vim.opt.pumheight = 10                    -- 補完メニューの最大表示行数
vim.opt.wildmode = "longest:full,full"    -- 補完の挙動（最長一致→フルマッチ）

vim.opt.clipboard = "unnamedplus"         -- システムクリップボードと連携
vim.opt.lazyredraw = false                -- マクロ実行中も再描画する
vim.opt.synmaxcol = 240                   -- シンタックスハイライトの最大列数
-- }}}

-- Find {{{
vim.opt.ignorecase = true                 -- 大文字小文字を区別しない
vim.opt.smartcase = true                  -- 大文字が含まれていたら区別する
vim.opt.imsearch = -1                     -- IME 検索モード（-1=iminsertに従う）
vim.opt.hlsearch = true                   -- 検索結果をハイライト
vim.opt.incsearch = true                  -- インクリメンタルサーチ
vim.opt.showmatch = true                  -- 対応する括弧を強調表示
vim.opt.wrap = true                       -- 長い行を折り返す
vim.opt.wrapmargin = 0                    -- 折り返し時の右マージン
vim.opt.wrapscan = true                   -- 検索時にファイル末尾で先頭に戻る
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"  -- ripgrep を使用
vim.opt.grepformat = "%f:%l:%c:%m"        -- grep 結果のフォーマット
-- }}}

-- Environment {{{
vim.opt.encoding = "utf-8"                -- 内部エンコーディング
vim.opt.fileencodings = "utf-8,cp932,sjis,iso-2022-jp,euc-jp"  -- 読み込み時の自動判定順
-- 改行コードの自動判定順（OS のネイティブ形式を優先）
local platform = require('core.platform')
vim.opt.fileformats = platform.is_windows and "dos,unix" or "unix,dos"
vim.opt.history = 10000                   -- コマンド履歴の保存数
vim.opt.autoread = true                   -- 外部でファイルが変更されたら自動で読み込む
-- }}}

-- Colors {{{
vim.opt.cursorline = false                -- カーソル行をハイライト
vim.opt.termguicolors = true              -- 24bit カラー有効化
vim.opt.signcolumn = "auto"               -- 左端のサイン列を自動表示（Git差分、診断等）
vim.opt.statuscolumn="%@SignCb@%s%=%T%@NumCb@%l│%T"  -- ステータスカラム表示形式
-- }}}

-- View {{{
vim.opt.number = true                     -- 行番号表示
vim.opt.list = false                      -- 不可視文字を表示しない
vim.opt.showcmd = true                    -- 入力中のコマンドを表示
vim.opt.wildmenu = true                   -- コマンドライン補完を拡張モードで
vim.opt.helplang = 'ja','en'              -- ヘルプの言語設定（日本語、英語）
-- }}}

-- Mouse {{{
vim.opt.mouse = "nvi"                     -- マウス有効化（ノーマル、ビジュアル、挿入）
vim.opt.mousefocus = false                -- マウスでフォーカス移動しない
vim.opt.mousehide = true                  -- 入力中はマウスカーソルを隠す
vim.opt.mousemoveevent = false            -- マウス移動イベントを無効化
vim.opt.mousemodel = "popup_setpos"       -- 右クリックでポップアップメニュー
vim.opt.mousescroll = "ver:3,hor:6"       -- マウススクロールの速度
vim.opt.mouseshape = ""                   -- マウスカーソルの形状（空=デフォルト）
vim.opt.mousetime = 500                   -- ダブルクリック判定時間（ミリ秒）
-- }}}

-- Folding {{{
vim.opt.foldenable = true                 -- 折りたたみを有効化
vim.opt.foldclose = ""                    -- 自動で折りたたみを閉じない
vim.opt.foldcolumn = "0"                  -- 折りたたみ列を表示しない
vim.opt.foldexpr = "0"                    -- 折りたたみ式（0=使用しない）
vim.opt.foldignore = "#"                  -- 折りたたみで無視する文字
vim.opt.foldlevel = 0                     -- 開始時の折りたたみレベル（0=全て閉じる）
vim.opt.foldlevelstart = -1               -- ファイルを開いた時の折りたたみレベル（-1=foldlevelに従う）
vim.opt.foldmarker = "{{{,}}}"            -- 折りたたみマーカー
vim.opt.foldminlines = 1                  -- 折りたたみの最小行数
vim.opt.foldnestmax = 20                  -- 折りたたみの最大ネスト数
vim.opt.foldopen = "block,hor,mark,percent,quickfix,search,tag,undo"  -- 折りたたみを開くトリガー
vim.opt.foldtext = "foldtext()"           -- 折りたたみ行の表示テキスト
vim.opt.foldmethod = "marker"             -- 折りたたみ方法（マーカー式）
-- }}}

-- swap, backup, undo, view {{{
vim.opt.undofile = true                   -- Undo履歴をファイルに保存
vim.opt.swapfile = true                   -- スワップファイルを作成
vim.opt.backup = true                     -- バックアップファイルを作成

-- viewfile option（カーソル位置・折りたたみの保存）
vim.opt.viewoptions = "cursor,curdir"     -- ビューに保存する内容

-- undofile option
vim.opt.undolevels = 1000                 -- Undoの保存段階数
vim.opt.undoreload = 10000                -- 再読み込み時のUndo保存行数

-- backupfile option
vim.opt.backupext = ".backup"             -- バックアップファイルの拡張子

-- swapfile options
vim.opt.updatetime = 30000                -- スワップファイル書き込み間隔（30秒）
vim.opt.updatecount = 500                 -- 500文字タイプするごとにスワップ保存

-- 保存場所
vim.opt.undodir = vim.fs.joinpath(vim.fn.stdpath("cache"), "undo")
vim.opt.directory = vim.fs.joinpath(vim.fn.stdpath("cache"), "swap")
vim.opt.backupdir = vim.fs.joinpath(vim.fn.stdpath("cache"), "backup")
vim.opt.viewdir = vim.fs.joinpath(vim.fn.stdpath("state"), "view")

-- 保存場所の自動作成
local function ensure_dir(dir)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

ensure_dir(vim.opt.undodir:get()[1])
ensure_dir(vim.opt.directory:get()[1])
ensure_dir(vim.opt.backupdir:get()[1])
ensure_dir(vim.opt.viewdir:get())
-- }}}
