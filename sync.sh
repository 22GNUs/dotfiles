#!/bin/bash

# 同步配置文件到 dotfiles 仓库的脚本
# 使用方法: ./sync.sh

set -e  # 遇到错误立即退出

# 颜色和样式定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}✨ [INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}🚀 [STEP]${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  [WARN]${NC} $1"; }
log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }

# 检查 rsync 是否安装
if ! command -v rsync &> /dev/null; then
    log_error "未找到 rsync，请先安装 rsync"
    exit 1
fi

# 定义同步目录
# 格式: "源路径|目标路径|描述|排除项"
SYNC_DIRS=(
    "$HOME/.config/fish|./.config/fish|🐟 Fish配置|--exclude=fish_variables"
    "$HOME/.config/ghostty|./.config/ghostty|👻 Ghostty配置|"
    "$HOME/.config/zellij|./.config/zellij|🗄️ Zellij配置|"
    "$HOME/.config/aerospace|./.config/aerospace|🚀 AeroSpace配置|"
)

# 定义同步文件
# 格式: "源路径|目标路径|描述"
SYNC_FILES=(
    "$HOME/.config/starship.toml|./.config/starship.toml|🚀 Starship配置"
    "$HOME/.ideavimrc|./.ideavimrc|⌨️  IDEA Vim配置"
    "$HOME/.tmux.conf|./.tmux.conf|🖥️  Tmux配置"
    "$HOME/.gitconfig|./.gitconfig|🔧 Git配置"
)

echo -e "${BOLD}=========================================="
echo -e "      🛠️  Dotfiles 同步工具启动"
echo -e "==========================================${NC}"

log_step "开始处理目录同步..."

# 处理目录同步
for item in "${SYNC_DIRS[@]}"; do
    IFS="|" read -r src dest desc exclude <<< "$item"
    if [[ -d "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        # 使用 rsync 同步目录
        if [[ -n "$exclude" ]]; then
            rsync -aq --delete "$exclude" "$src/" "$dest/"
        else
            rsync -aq --delete "$src/" "$dest/"
        fi
        log_info "同步成功: $desc"
    else
        log_warn "跳过目录: $desc (源不存在)"
    fi
done

echo ""
log_step "开始处理文件同步..."

# 处理文件同步
for item in "${SYNC_FILES[@]}"; do
    IFS="|" read -r src dest desc <<< "$item"
    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        log_info "同步成功: $desc"
    else
        log_warn "跳过文件: $desc (源不存在)"
    fi
done

echo -e "\n${BOLD}=========================================="
echo -e "      ✅ 所有的配置文件同步完成!"
echo -e "==========================================${NC}"
