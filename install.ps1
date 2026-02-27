#Requires -Version 5.1
<#
.SYNOPSIS
    Neovim dotfiles インストールスクリプト（Windows）

.DESCRIPTION
    1. 必須依存関係のチェックとインストール（winget 経由）
    2. シンボリックリンクの作成
       - $env:LOCALAPPDATA\nvim -> dotfiles\nvim
       - ~/.config/nvim -> $env:LOCALAPPDATA\nvim（任意）

.NOTES
    管理者権限 または 開発者モード が必要（シンボリックリンク作成のため）
    冪等: 再実行しても既存の正しいリンク・インストール済みツールは変更しない
#>

[CmdletBinding()]
param(
    [switch]$SkipOptional,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- ユーティリティ ---

function Write-Step  { param([string]$Msg) Write-Host "[*] $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "[+] $Msg" -ForegroundColor Green }
function Write-Skip  { param([string]$Msg) Write-Host "[-] $Msg" -ForegroundColor DarkGray }
function Write-Warn  { param([string]$Msg) Write-Host "[!] $Msg" -ForegroundColor Yellow }
function Write-Fail  { param([string]$Msg) Write-Host "[x] $Msg" -ForegroundColor Red }

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-WithWinget {
    param(
        [string]$PackageId,
        [string]$DisplayName,
        [string]$TestCommand
    )

    if (Test-CommandExists $TestCommand) {
        Write-Ok "$DisplayName は既にインストール済み"
        return $true
    }

    if (-not (Test-CommandExists 'winget')) {
        Write-Fail "winget が見つかりません。手動で $DisplayName をインストールしてください"
        return $false
    }

    Write-Step "$DisplayName をインストール中 ($PackageId) ..."
    if ($DryRun) {
        Write-Skip "[DryRun] winget install -e --id $PackageId"
        return $true
    }

    winget install -e --id $PackageId --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "$DisplayName のインストールに失敗しました（exit code: $LASTEXITCODE）"
        return $false
    }

    Write-Ok "$DisplayName をインストールしました"
    Write-Warn "PATH を反映するためシェルの再起動が必要な場合があります"
    return $true
}

function New-SymlinkSafe {
    param(
        [string]$LinkPath,
        [string]$TargetPath
    )

    # 既存リンクのチェック
    if (Test-Path $LinkPath) {
        $item = Get-Item $LinkPath -Force
        if ($item.LinkType -eq 'SymbolicLink') {
            $existingTarget = $item.Target
            if ($existingTarget -eq $TargetPath) {
                Write-Ok "シンボリックリンク既存: $LinkPath -> $TargetPath"
                return $true
            }
            Write-Warn "既存リンクのターゲットが異なります: $existingTarget (期待: $TargetPath)"
            Write-Warn "既存リンクを削除して再作成します"
            if (-not $DryRun) {
                Remove-Item $LinkPath -Force
            }
        }
        else {
            Write-Fail "$LinkPath は既に存在し、シンボリックリンクではありません。手動で確認してください"
            return $false
        }
    }

    # 親ディレクトリの作成
    $parent = Split-Path $LinkPath -Parent
    if (-not (Test-Path $parent)) {
        if ($DryRun) {
            Write-Skip "[DryRun] mkdir $parent"
        }
        else {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
    }

    Write-Step "シンボリックリンク作成: $LinkPath -> $TargetPath"
    if ($DryRun) {
        Write-Skip "[DryRun] New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath"
        return $true
    }

    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
        Write-Ok "リンク作成完了"
        return $true
    }
    catch {
        Write-Fail "シンボリックリンクの作成に失敗: $_"
        Write-Warn "管理者権限で実行するか、開発者モードを有効にしてください"
        Write-Warn "  設定 -> システム -> 開発者向け -> 開発者モード"
        return $false
    }
}

# --- メイン ---

function Main {
    Write-Host ""
    Write-Host "=== Neovim dotfiles installer (Windows) ===" -ForegroundColor White
    Write-Host ""

    # dotfiles ルートの推定（このスクリプトの配置場所）
    $dotfilesRoot = Split-Path $PSCommandPath -Parent
    $nvimConfigSource = Join-Path $dotfilesRoot 'nvim'

    if (-not (Test-Path $nvimConfigSource)) {
        Write-Fail "nvim/ ディレクトリが見つかりません: $nvimConfigSource"
        exit 1
    }

    Write-Step "dotfiles root: $dotfilesRoot"
    Write-Step "nvim config:   $nvimConfigSource"
    Write-Host ""

    # ===== フェーズ 1: 必須依存関係 =====
    Write-Host "--- 必須依存関係 ---" -ForegroundColor White
    $allOk = $true

    $requiredDeps = @(
        @{ PackageId = 'Neovim.Neovim';        DisplayName = 'Neovim';  TestCommand = 'nvim' }
        @{ PackageId = 'Git.Git';               DisplayName = 'Git';     TestCommand = 'git' }
        @{ PackageId = 'DenoLand.Deno';         DisplayName = 'Deno';    TestCommand = 'deno' }
        @{ PackageId = 'OpenJS.NodeJS.LTS';     DisplayName = 'Node.js'; TestCommand = 'node' }
        @{ PackageId = 'BurntSushi.ripgrep.MSVC'; DisplayName = 'ripgrep'; TestCommand = 'rg' }
    )

    foreach ($dep in $requiredDeps) {
        $result = Install-WithWinget @dep
        if (-not $result) { $allOk = $false }
    }

    # GCC（MSYS2 経由のため特別扱い）
    if (Test-CommandExists 'gcc') {
        Write-Ok "GCC は既にインストール済み"
    }
    else {
        Write-Warn "GCC が見つかりません（treesitter パーサーのビルドに必要）"
        Write-Warn "MSYS2 経由でインストールしてください:"
        Write-Warn "  winget install MSYS2.MSYS2"
        Write-Warn "  # MSYS2 MinGW 64-bit シェルで:"
        Write-Warn "  pacman -S mingw-w64-x86_64-gcc"
        Write-Warn "  # MinGW の bin を PATH に追加"
        $allOk = $false
    }

    Write-Host ""

    # ===== フェーズ 2: 任意依存関係 =====
    if (-not $SkipOptional) {
        Write-Host "--- 任意依存関係 ---" -ForegroundColor White

        $optionalDeps = @(
            @{ PackageId = 'Microsoft.PowerShell'; DisplayName = 'PowerShell 7'; TestCommand = 'pwsh' }
        )

        foreach ($dep in $optionalDeps) {
            Install-WithWinget @dep | Out-Null
        }

        Write-Host ""
    }

    # ===== フェーズ 3: シンボリックリンク =====
    Write-Host "--- シンボリックリンク ---" -ForegroundColor White

    # メインリンク: $env:LOCALAPPDATA\nvim -> dotfiles\nvim
    $nvimAppData = Join-Path $env:LOCALAPPDATA 'nvim'
    $linkOk = New-SymlinkSafe -LinkPath $nvimAppData -TargetPath $nvimConfigSource

    # エイリアスリンク: ~/.config/nvim -> $env:LOCALAPPDATA\nvim（任意）
    if ($linkOk) {
        $configDir = Join-Path $HOME '.config'
        $nvimConfigAlias = Join-Path $configDir 'nvim'
        New-SymlinkSafe -LinkPath $nvimConfigAlias -TargetPath $nvimAppData | Out-Null
    }

    Write-Host ""

    # ===== サマリー =====
    Write-Host "--- 完了 ---" -ForegroundColor White
    if ($allOk) {
        Write-Ok "全ての依存関係がインストール済みです"
    }
    else {
        Write-Warn "一部の依存関係が不足しています。上記の警告を確認してください"
    }
    Write-Step "nvim を起動するとプラグインが自動インストールされます"
    Write-Host ""
}

Main
