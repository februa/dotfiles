# Neovim Configuration

Windows (PowerShell 7) 向けの Neovim 設定。
プラグインマネージャーに [dpp.vim](https://github.com/Shougo/dpp.vim)（Deno ベース）を使用。

## 依存関係のインストール

### 必須

#### 1. Neovim 0.11+

```powershell
winget install Neovim.Neovim
```

#### 2. Git

```powershell
winget install Git.Git
```

#### 3. Deno

dpp.vim / denops.vim の実行に必要。

```powershell
irm https://deno.land/install.ps1 | iex
```

#### 4. Node.js 18+

mason.nvim による LSP サーバーのインストールに必要。

```powershell
winget install OpenJS.NodeJS.LTS
```

#### 5. C コンパイラ（GCC）

nvim-treesitter のパーサービルドに必要。

```powershell
# MSYS2 経由
winget install MSYS2.MSYS2
# MSYS2 MinGW 64-bit シェルで:
pacman -S mingw-w64-x86_64-gcc
```

`gcc` にパスが通っていることを確認：
```powershell
gcc --version
```

#### 6. ripgrep

ddu-source-rg、grepprg で使用。

```powershell
winget install BurntSushi.ripgrep
```

### 任意

#### PowerShell 7

init.lua で `pwsh` を shell として設定している。未インストールでも動作するが推奨。

```powershell
winget install Microsoft.PowerShell
```

## セットアップ手順

### 1. 配置

dotfiles リポジトリとして管理する場合、実体を任意の場所に clone し、
シンボリックリンクで Neovim の config ディレクトリに接続する。

#### Windows

```powershell
# dotfiles リポジトリを clone（実体）
git clone https://github.com/{your-username}/dotfiles.git "$HOME\dotfiles"

# Neovim の config ディレクトリにシンボリックリンク（管理者権限の PowerShell で実行）
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$HOME\dotfiles\nvim"

# ~/.config/nvim からもアクセスできるようにする（任意）
New-Item -ItemType Directory -Force "$HOME\.config"
New-Item -ItemType SymbolicLink -Path "$HOME\.config\nvim" -Target "$env:LOCALAPPDATA\nvim"
```

> **Note**: Windows でシンボリックリンクを作成するには管理者権限が必要。
> または「開発者モード」を有効にすれば一般ユーザーでも作成可能
> （設定 → システム → 開発者向け → 開発者モード）。

#### Linux / macOS

```bash
git clone https://github.com/{your-username}/dotfiles.git ~/dotfiles

# ~/.config/nvim がそのまま config ディレクトリ
ln -s ~/dotfiles/nvim ~/.config/nvim
```

#### リンク構成の全体像

```
~/dotfiles/nvim/          ← 実体（git 管理対象）
  ↑
~/AppData/Local/nvim      ← symlink（Neovim が参照する config ディレクトリ）
  ↑
~/.config/nvim            ← symlink（利便性のためのエイリアス、任意）
```

UNIX 系 OS の場合は `~/.config/nvim` が直接 config ディレクトリなので、
`~/dotfiles/nvim` → `~/.config/nvim` の1段リンクで済む。

### 2. 初回起動

```
nvim 起動 → 必須リポジトリが自動 clone → state 構築
→ 全プラグイン自動インストール → state 再構築 → in-place リロード
→ LSP サーバー自動インストール → 全プラグイン利用可能（再起動不要）
```

### 3. フォーマッターのインストール

Neovim 内で：

```vim
:MasonInstall prettierd
```

### 4. ddu-source-rg の Windows 修正

クリーンインストール後、ddu-source-rg に Windows 固有のバグ修正が必要：

`%LOCALAPPDATA%\nvim-data\dpp\repos\github.com\Shougo\ddu-source-rg\denops\@ddu-sources\rg.ts` の
`stdin: "null"` を `stdin: "piped"` に変更し、直後に `proc.stdin.close();` を追加する。

詳細は [docs/dpp_pitfalls.md](docs/dpp_pitfalls.md) を参照。

## ファイル構成

```
nvim/
├── README.md                     このファイル
├── init.lua                      エントリポイント（load_extensions フラグで拡張機能を制御）
├── lua/
│   ├── core/                     基本設定（常に読み込み）
│   │   ├── options.lua           vim.opt 設定群
│   │   ├── keymaps.lua           プラグイン非依存キーマップ
│   │   ├── autocmds.lua          基本 autocmd・ユーティリティコマンド
│   │   ├── project.lua           プロジェクト検出（npm_root 等）
│   │   └── ui.lua                フォールバック UI（myline ステータスライン）
│   ├── config/
│   │   └── settings.lua          集約設定（LSP サーバーリスト等）
│   └── plugins/                  プラグイン設定（拡張機能モード時のみ読み込み）
│       ├── lsp.lua               LSP 設定（mason + mason-lspconfig）
│       ├── cmp.lua               補完設定（nvim-cmp）
│       ├── colorscheme.lua       カラースキーム設定（catppuccin）
│       ├── lualine.lua           ステータスライン設定
│       ├── treesitter.lua        Treesitter 設定
│       ├── ddu.lua               ddu.vim 設定（キーマップ + グローバル設定）
│       ├── toggleterm.lua        ターミナル・コード実行
│       ├── which-key.lua         キー操作ガイド
│       ├── avante.lua            AI アシスタント
│       └── zk.lua                Zettelkasten ノート管理
├── dpp/
│   ├── init.lua                  dpp エントリポイント（ブートストラップ + state ロード）
│   ├── utils.lua                 共通定数・関数（dpp_base, clear_module_cache 等）
│   ├── bootstrap.lua             必須リポジトリの git clone ロジック
│   ├── reload.lua                in-place リロード（dpp_reload）
│   ├── commands.lua              ユーザーコマンド定義（:DppMakeState 等）
│   ├── load_plugins.ts           TOML → プラグインリスト変換（TypeScript）
│   └── plugins.toml              プラグイン定義
├── autoload/dpp/ext/
│   └── installer.vim             dpp installer の表示カスタマイズ（fidget 連携）
├── after/ftplugin/               ファイルタイプ別設定（ddu-ff, ddu-filer 等含む）
└── docs/                         ドキュメント
```

### 設計方針

`vim.g.load_extensions = false` にすれば拡張機能を一切読み込まず、
`core/` の基本設定 + フォールバック UI のみで Neovim が起動する。
拡張機能有効時は dpp.vim 経由で全プラグインが自動インストール・管理される。

## カスタムコマンド

| コマンド | 説明 |
|---------|------|
| `:DppInstall` | 新規プラグインをインストール（state 再構築 → clone → リロード） |
| `:DppUpdate` | プラグインを更新して state 再構築 |
| `:DppMakeState` | plugins.toml の変更を反映（state 再構築のみ） |
| `:DppClearCache` | dpp キャッシュを完全削除（次回起動時に再構築） |
| `:DppClean` | plugins.toml から削除されたプラグインのディレクトリを削除 |
| `:Messages` | `:messages` の内容をクリップボードにコピー |

## 主要プラグイン

| カテゴリ | プラグイン |
|---------|-----------|
| プラグインマネージャー | dpp.vim + denops.vim |
| ファジーファインダー | ddu.vim（`sN` `s;` `sm` `s/` `sg`） |
| 補完 | nvim-cmp + cmp-nvim-lsp |
| LSP | nvim-lspconfig + mason.nvim |
| Git | gitsigns.nvim + vim-fugitive（`gs` `gd` `gb` `gl`） |
| テーマ | catppuccin |
| ステータスライン | lualine.nvim |
| フォーマッター | conform.nvim（prettierd） |

## ドキュメント

dpp.vim は公式ドキュメントが最小限のため、セットアップで得た知見を `docs/` にまとめている。
特に初回インストールのフローやハマりポイントは必読：

- [dpp_setup_guide.md](docs/dpp_setup_guide.md) — セットアップ手順・内部フロー図
- [dpp_pitfalls.md](docs/dpp_pitfalls.md) — ハマりポイント集
- [dpp_commands.md](docs/dpp_commands.md) — コマンドリファレンス
- [keymaps.md](docs/keymaps.md) — キーマップ・プラグイン操作リファレンス
