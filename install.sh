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

# Neovim のバージョン要件を満たすか判定（0.11+ 必須）
# 戻り値: 0 = OK, 1 = バージョン不足 or 未インストール
nvim_version_ok() {
    command_exists nvim || return 1
    local ver
    ver="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
    local major minor
    major="$(echo "$ver" | cut -d. -f1)"
    minor="$(echo "$ver" | cut -d. -f2)"
    # 0.11+ または 1.x+ なら OK
    if [ "${major:-0}" -ge 1 ] || { [ "${major:-0}" -eq 0 ] && [ "${minor:-0}" -ge 11 ]; }; then
        return 0
    fi
    return 1
}

# Neovim インストール（apt で古い場合は GitHub Releases からフォールバック）
# apt (Ubuntu/Debian) のリポジトリは 0.9 程度で止まっていることが多い
NVIM_REQUIRED_VERSION="0.11"
NVIM_GITHUB_TAG="v0.11.6"

install_neovim() {
    if nvim_version_ok; then
        ok "Neovim $(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) は要件を満たしています"
        return 0
    fi

    # 既にインストールされているがバージョン不足の場合
    if command_exists nvim; then
        local current
        current="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
        warn "Neovim $current が検出されました（${NVIM_REQUIRED_VERSION}+ が必要）"
    fi

    # macOS / brew: brew なら最新が入る
    if [ "$PKG_MGR" = "brew" ]; then
        step "Neovim をインストール中 (brew) ..."
        if $DRY_RUN; then
            skip "[DryRun] brew install neovim"
            return 0
        fi
        brew install neovim
        if nvim_version_ok; then
            ok "Neovim をインストールしました (brew)"
            return 0
        fi
    fi

    # Linux: GitHub Releases から tarball を取得
    local os
    os="$(detect_os)"
    if [ "$os" = "linux" ]; then
        step "Neovim を GitHub Releases からインストール中 ($NVIM_GITHUB_TAG) ..."
        local url="https://github.com/neovim/neovim/releases/download/${NVIM_GITHUB_TAG}/nvim-linux-x86_64.tar.gz"
        local install_dir="/opt/nvim"

        if $DRY_RUN; then
            skip "[DryRun] curl -> /opt/nvim, symlink /usr/local/bin/nvim"
            return 0
        fi

        local tmp
        tmp="$(mktemp -d)"
        curl -fsSL "$url" -o "$tmp/nvim.tar.gz"
        sudo rm -rf "$install_dir"
        sudo mkdir -p "$install_dir"
        sudo tar -xzf "$tmp/nvim.tar.gz" -C "$install_dir" --strip-components=1
        sudo ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
        rm -rf "$tmp"

        # PATH に /usr/local/bin があることを確認
        export PATH="/usr/local/bin:$PATH"

        if nvim_version_ok; then
            ok "Neovim $NVIM_GITHUB_TAG をインストールしました (/opt/nvim)"
            return 0
        else
            fail "Neovim のインストールに失敗しました"
            return 1
        fi
    fi

    # それ以外: パッケージマネージャにフォールバック
    install_dep "Neovim" "nvim" "neovim" "neovim" "neovim" "neovim"
    if ! nvim_version_ok; then
        warn "パッケージマネージャの Neovim は ${NVIM_REQUIRED_VERSION}+ を満たしません"
        warn "手動でアップグレードしてください: https://github.com/neovim/neovim/releases"
        return 1
    fi
    return 0
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

    # Neovim: apt は 0.9 程度で止まっていることが多いため専用ロジック
    install_neovim || all_ok=false

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
