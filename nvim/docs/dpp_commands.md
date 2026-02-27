# カスタムコマンドリファレンス

`dpp/commands.lua` と `lua/core/autocmds.lua` で定義しているカスタムコマンドの一覧。

## プラグイン管理コマンド

### :DppInstall

state を再構築し、未インストールのプラグインを clone し、再度 state を構築する。

```
実行タイミング: plugins.toml に新しいプラグインを追加した後
実行後: in-place リロードが自動実行される（再起動不要）
```

**内部処理**:
1. `dpp#make_state` で state 構築（TOML のプラグインリストを認識させる）
2. `dpp#async_ext_action('installer', 'install')` で未 clone プラグインを clone
3. `Dpp:ext:installer:updateDone` 後に `dpp#make_state` を再実行（.dpp マージ）
4. `dpp_reload()` で in-place リロード

**使い方**:
```vim
:DppInstall
" → clone → state 再構築 → リロード → 全プラグイン利用可能
```

---

### :DppUpdate

インストール済みプラグインを git pull で最新に更新し、state を再構築する。

```
実行タイミング: 定期的なプラグイン更新時
実行後: in-place リロードが自動実行される（再起動不要）
```

**内部処理**:
1. `dpp#async_ext_action('installer', 'update')` で全プラグインを更新
2. `Dpp:ext:installer:updateDone` 後に `dpp#make_state` を再実行
3. `dpp_reload()` で in-place リロード

**使い方**:
```vim
:DppUpdate
" → 更新 → state 再構築 → リロード → 全プラグイン利用可能
```

---

### :DppMakeState

plugins.toml を再読み込みして state（startup.vim + state.vim + .dpp マージ）を再構築する。
プラグインの clone/update は行わない。

```
実行タイミング: plugins.toml のフック設定やオプションを変更した後
実行後: in-place リロードが自動実行される（再起動不要）
```

**使い方**:
```vim
:DppMakeState
" → "dpp state rebuilt!" と表示される
```

---

### :DppClean

plugins.toml に記載されていないプラグインディレクトリを検出し、削除する。

```
実行タイミング: plugins.toml からプラグインを削除した後
実行後: :DppMakeState で state を更新する
```

**内部処理**:
1. state を再構築して最新のプラグインリストを取得
2. repos ディレクトリを走査し、管理対象外のディレクトリを検出
3. 削除候補を表示し、確認後に削除

**使い方**:
```vim
:DppClean
" → "Orphan plugin directories:" と削除候補が表示される
" → "Delete these directories? [y/N]:" と確認される
" → y を入力して削除
:DppMakeState  " state を更新
```

---

### :DppClearCache

dpp のキャッシュ（startup.vim, state.vim, .dpp ディレクトリ）を完全削除する。
次回起動時に state が自動再構築される。

```
実行タイミング: プラグインの状態がおかしい時のリセット手段
実行後: Neovim を再起動する
```

**使い方**:
```vim
:DppClearCache
" → "dpp cache cleared!" と表示される
" → Neovim を再起動する
```

---

## ユーティリティコマンド

### :Messages

`:messages` の出力をシステムクリップボードにコピーする。

```
実行タイミング: エラーログを貼り付けたい時
```

**使い方**:
```vim
:Messages
" → "Copied :messages to clipboard" と表示される
" → Ctrl+V で任意の場所に貼り付け
```

---

## 日常ワークフロー

### 新しいプラグインを追加する

```
1. plugins.toml にプラグイン定義を追加
2. :DppInstall を実行（自動リロード）
```

### プラグインの設定を変更する

```
1. plugins.toml の hook_add / hook_source を編集
2. :DppMakeState を実行（自動リロード）
```

### プラグインを削除する

```
1. plugins.toml からプラグイン定義を削除
2. :DppClean を実行（不要ディレクトリを削除）
3. :DppMakeState を実行（state を更新、自動リロード）
```

### プラグインを一括更新する

```
1. :DppUpdate を実行（自動リロード）
```

### 何かおかしい時

```
1. :Messages でログを確認
2. :DppMakeState で state を再構築
3. それでもダメなら :DppClearCache → Neovim を再起動
4. 最終手段 — 完全リセット:
   PowerShell: Remove-Item -Recurse -Force "$env:LOCALAPPDATA\nvim-data\dpp"
   → Neovim を起動（自動で全復旧）
```
