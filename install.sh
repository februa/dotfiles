#!/usr/bin/env bash
# Neovim dotfiles インストールスクリプト（Linux / macOS）
#
# 使い方:
#   ./install.sh              通常インストール
#   ./install.sh --skip-optional  任意依存関係をスキップ
#   ./install.sh --dry-run    実際のインストール・リンク作成を行わない
#
# 依存関係:
#   必須: neovim(0.11+), git, deno, node(18+), gcc/cc, ripgrep
#   任意: (なし — Linux/macOS では pwsh は不要)
#
# シンボリックリンク:
#   ~/.config/nvim -> dotfiles/nvim

set -euo pipefail

# --- オプション解析 ---
SKIP_OPTIONAL=false
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --skip-optional) SKIP_OPTIONAL=true ;;
        --dry-run)       DRY_RUN=true ;;
        -h|--help)
            echo "Usage: $0 [--skip-optional] [--dry-run]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

# --- ユーティリティ ---

step()  { printf '\033[36m[*] %s\033[0m\n' "$*"; }
ok()    { printf '\033[32m[+] %s\033[0m\n' "$*"; }
skip()  { printf '\033[90m[-] %s\033[0m\n' "$*"; }
warn()  { printf '\033[33m[!] %s\033[0m\n' "$*"; }
fail()  { printf '\033[31m[x] %s\033[0m\n' "$*"; }

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

detect_pkg_manager() {
    local os="$1"
    if [ "$os" = "macos" ]; then
        if command_exists brew; then
            echo "brew"
            return
        fi
    fi
    # Linux: 優先順に検出
    if command_exists apt-get; then echo "apt"
    elif command_exists dnf; then echo "dnf"
    elif command_exists pacman; then echo "pacman"
    elif command_exists brew; then echo "brew"
    else echo "none"
    fi
}

# パッケージマネージャ経由でインストール
# 引数: display_name test_command pkg_apt pkg_dnf pkg_pacman pkg_brew
install_dep() {
    local display_name="$1"
    local test_cmd="$2"
    local pkg_apt="$3"
    local pkg_dnf="$4"
    local pkg_pacman="$5"
    local pkg_brew="$6"

    if command_exists "$test_cmd"; then
        ok "$display_name は既にインストール済み"
        return 0
    fi

    local pkg=""
    case "$PKG_MGR" in
        apt)    pkg="$pkg_apt" ;;
        dnf)    pkg="$pkg_dnf" ;;
        pacman) pkg="$pkg_pacman" ;;
        brew)   pkg="$pkg_brew" ;;
        none)
            fail "$display_name が見つかりません。手動でインストールしてください"
            return 1
            ;;
    esac

    if [ -z "$pkg" ] || [ "$pkg" = "-" ]; then
        warn "$display_name: $PKG_MGR 用のパッケージ名が未定義。手動でインストールしてください"
        return 1
    fi

    step "$display_name をインストール中 ($PKG_MGR: $pkg) ..."

    if $DRY_RUN; then
        skip "[DryRun] $PKG_MGR install $pkg"
        return 0
    fi

    case "$PKG_MGR" in
        apt)    sudo apt-get update -qq && sudo apt-get install -y -qq "$pkg" ;;
        dnf)    sudo dnf install -y -q "$pkg" ;;
        pacman) sudo pacman -S --noconfirm --needed "$pkg" ;;
        brew)   brew install "$pkg" ;;
    esac

    if command_exists "$test_cmd"; then
        ok "$display_name をインストールしました"
        return 0
    else
        fail "$display_name のインストール後もコマンドが見つかりません。PATH を確認してください"
        return 1
    fi
}

# Deno は公式インストーラ経由（パッケージマネージャにないことが多い）
install_deno() {
    if command_exists deno; then
        ok "Deno は既にインストール済み"
        return 0
    fi

    step "Deno をインストール中（公式インストーラ）..."

    if $DRY_RUN; then
        skip "[DryRun] curl -fsSL https://deno.land/install.sh | sh"
        return 0
    fi

    curl -fsSL https://deno.land/install.sh | sh

    # インストーラが ~/.deno/bin に配置する場合の PATH 追加
    if [ -d "$HOME/.deno/bin" ]; then
        export PATH="$HOME/.deno/bin:$PATH"
    fi

    if command_exists deno; then
        ok "Deno をインストールしました"
        return 0
    else
        warn "Deno インストール後にコマンドが見つかりません。~/.deno/bin を PATH に追加してください"
        return 1
    fi
}

# シンボリックリンクの作成（冪等）
create_symlink() {
    local link_path="$1"
    local target_path="$2"

    if [ -L "$link_path" ]; then
        local existing_target
        existing_target="$(readlink -f "$link_path" 2>/dev/null || readlink "$link_path")"
        local resolved_target
        resolved_target="$(cd "$target_path" 2>/dev/null && pwd -P)"

        if [ "$existing_target" = "$resolved_target" ]; then
            ok "シンボリックリンク既存: $link_path -> $target_path"
            return 0
        fi

        warn "既存リンクのターゲットが異なります: $existing_target (期待: $resolved_target)"
        warn "既存リンクを削除して再作成します"
        if ! $DRY_RUN; then
            rm "$link_path"
        fi
    elif [ -e "$link_path" ]; then
        fail "$link_path は既に存在し、シンボリックリンクではありません。手動で確認してください"
        return 1
    fi

    # 親ディレクトリの作成
    local parent
    parent="$(dirname "$link_path")"
    if [ ! -d "$parent" ]; then
        if $DRY_RUN; then
            skip "[DryRun] mkdir -p $parent"
        else
            mkdir -p "$parent"
        fi
    fi

    step "シンボリックリンク作成: $link_path -> $target_path"
    if $DRY_RUN; then
        skip "[DryRun] ln -s $target_path $link_path"
        return 0
    fi

    ln -s "$target_path" "$link_path"
    ok "リンク作成完了"
    return 0
}

# --- メイン ---

main() {
    echo ""
    echo "=== Neovim dotfiles installer ($(detect_os)) ==="
    echo ""

    # dotfiles ルートの推定
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    local dotfiles_root="$script_dir"
    local nvim_config_source="$dotfiles_root/nvim"

    if [ ! -d "$nvim_config_source" ]; then
        fail "nvim/ ディレクトリが見つかりません: $nvim_config_source"
        exit 1
    fi

    local os
    os="$(detect_os)"
    PKG_MGR="$(detect_pkg_manager "$os")"

    step "dotfiles root: $dotfiles_root"
    step "nvim config:   $nvim_config_source"
    step "OS: $os / パッケージマネージャ: $PKG_MGR"
    echo ""

    # ===== フェーズ 1: 必須依存関係 =====
    echo "--- 必須依存関係 ---"
    local all_ok=true

    # Neovim: apt のバージョンが古い場合が多いので警告
    #               apt         dnf        pacman     brew
    install_dep "Neovim"  "nvim" \
        "neovim"    "neovim"    "neovim"    "neovim" \
        || all_ok=false

    # バージョンチェック（0.11+ 必須）
    if command_exists nvim; then
        local nvim_version
        nvim_version="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
        local nvim_major nvim_minor
        nvim_major="$(echo "$nvim_version" | cut -d. -f1)"
        nvim_minor="$(echo "$nvim_version" | cut -d. -f2)"
        if [ "${nvim_major:-0}" -eq 0 ] && [ "${nvim_minor:-0}" -lt 11 ]; then
            warn "Neovim $nvim_version が検出されました。0.11+ が必要です"
            warn "PPA/unstable リポジトリ、snap、または brew でアップグレードしてください"
            all_ok=false
        fi
    fi

    install_dep "Git"     "git"  "git"       "git"       "git"       "git"        || all_ok=false
    install_deno                                                                   || all_ok=false
    install_dep "Node.js" "node" "nodejs"    "nodejs"    "nodejs"    "node"        || all_ok=false
    install_dep "ripgrep" "rg"   "ripgrep"   "ripgrep"   "ripgrep"   "ripgrep"     || all_ok=false

    # C コンパイラ
    if command_exists gcc || command_exists cc; then
        ok "C コンパイラは既にインストール済み"
    else
        install_dep "GCC" "gcc" \
            "build-essential" "gcc" "gcc" "gcc" \
            || all_ok=false
    fi

    echo ""

    # ===== フェーズ 2: シンボリックリンク =====
    echo "--- シンボリックリンク ---"

    local nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    create_symlink "$nvim_config_dir" "$nvim_config_source" || all_ok=false

    echo ""

    # ===== サマリー =====
    echo "--- 完了 ---"
    if $all_ok; then
        ok "全ての依存関係がインストール済みです"
    else
        warn "一部の依存関係が不足しています。上記の警告を確認してください"
    fi
    step "nvim を起動するとプラグインが自動インストールされます"
    echo ""
}

main
