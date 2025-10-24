#!/bin/bash

# 同步配置文件到dotfiles仓库的脚本
# 使用方法: ./sync.sh

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查源文件是否存在并复制
sync_file() {
    local src="$1"
    local dest="$2"
    local description="$3"
    
    if [[ -f "$src" ]]; then
        cp "$src" "$dest"
        log_info "已同步: $description"
    else
        log_warn "跳过: $description (源文件不存在: $src)"
    fi
}

# 检查源目录是否存在并复制
sync_dir() {
    local src="$1"
    local dest="$2"
    local description="$3"
    
    if [[ -d "$src" ]]; then
        rm -rf "$dest"
        cp -r "$src" "$dest"
        log_info "已同步: $description"
    else
        log_warn "跳过: $description (源目录不存在: $src)"
    fi
}

# 确保目标目录存在
mkdir -p ./.config

log_info "开始同步配置文件..."

# 同步单个文件
sync_file "$HOME/.config/starship.toml" "./.config/starship.toml" "Starship配置"
sync_file "$HOME/.ideavimrc" "./.ideavimrc" "IDEA Vim配置"
sync_file "$HOME/.tmux.conf" "./.tmux.conf" "Tmux配置"
sync_file "$HOME/.gitconfig" "./.gitconfig" "Git配置"

# 同步配置目录
sync_dir "$HOME/.config/fish" "./.config/fish" "Fish Shell配置"
sync_dir "$HOME/.config/alacritty" "./.config/alacritty" "Alacritty终端配置"
sync_dir "$HOME/.config/aerospace" "./.config/aerospace" "Aerospace窗口管理器配置"
sync_dir "$HOME/.config/sketchybar" "./.config/sketchybar" "SketchyBar配置"
sync_dir "$HOME/.config/ghostty" "./.config/ghostty" "Ghostty终端配置"
sync_dir "$HOME/.config/zellij" "./.config/zellij" "Zellij终端复用器配置"

log_info "配置文件同步完成!"
