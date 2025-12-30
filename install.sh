#!/bin/bash

# 将仓库中的配置文件安装到用户目录的脚本
# 使用方法: ./install.sh

set -e

# 颜色和样式定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

log_info() { echo -e "${GREEN}✨ [INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}🚀 [STEP]${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  [WARN]${NC} $1"; }
log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }

# 定义同步目录 (与 sync.sh 相反)
# 格式: "源路径(仓库)|目标路径(用户)|描述"
SYNC_DIRS=(
    ".config/fish|$HOME/.config/fish|🐟 Fish配置"
    ".config/ghostty|$HOME/.config/ghostty|👻 Ghostty配置"
    ".config/zellij|$HOME/.config/zellij|🗄️ Zellij配置"
    ".config/aerospace|$HOME/.config/aerospace|🚀 AeroSpace配置"
    ".config/nvim|$HOME/.config/nvim|📝 Neovim配置"
    ".config/opencode|$HOME/.config/opencode|🤖 OpenCode配置"
)

# 定义同步文件
# 格式: "源路径(仓库)|目标路径(用户)|描述"
SYNC_FILES=(
    ".config/starship.toml|$HOME/.config/starship.toml|🚀 Starship配置"
    ".ideavimrc|$HOME/.ideavimrc|⌨️  IDEA Vim配置"
    ".tmux.conf|$HOME/.tmux.conf|🖥️  Tmux配置"
)

echo -e "${BOLD}=========================================="
echo -e "      🔗 Dotfiles 软链接工具 (Repo -> Home)"
echo -e "==========================================${NC}"

# 获取仓库根目录的绝对路径
DOTFILES_ROOT=$(pwd)

# 创建备份目录
mkdir -p "$BACKUP_DIR"
log_info "冲突文件将备份至: $BACKUP_DIR"

# 处理软链接的通用函数
create_symlink() {
    local src_rel=$1
    local dest=$2
    local desc=$3
    local src="$DOTFILES_ROOT/$src_rel"

    if [[ ! -e "$src" ]]; then
        log_error "错误: 仓库中找不到源 $src"
        return
    fi

    if [[ -L "$dest" ]]; then
        local current_link
        current_link=$(readlink "$dest")
        if [[ "$current_link" == "$src" ]]; then
            log_info "已连接: $desc"
            return
        fi
        # 如果是软链接但指向不对，先删除
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        # 如果是普通文件或目录，备份它
        mkdir -p "$(dirname "$BACKUP_DIR/${dest#$HOME/}")"
        mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
        log_warn "已备份存量配置: $desc"
    fi

    # 创建目标父目录
    mkdir -p "$(dirname "$dest")"
    # 创建软链接
    ln -s "$src" "$dest"
    log_info "链接成功: $desc"
}

# 1. 处理目录
log_step "开始建立目录链接..."
for item in "${SYNC_DIRS[@]}"; do
    IFS="|" read -r src dest desc <<< "$item"
    create_symlink "$src" "$dest" "$desc"
done

# 2. 处理文件
echo ""
log_step "开始建立文件链接..."
for item in "${SYNC_FILES[@]}"; do
    IFS="|" read -r src dest desc <<< "$item"
    create_symlink "$src" "$dest" "$desc"
done

echo -e "\n${BOLD}=========================================="
echo -e "      🎉 软链接建立完成!"
echo -e "==========================================${NC}"

# 3. 初始化 Fish 主题
log_step "初始化 Fish 主题..."
FISH_THEME="TokyoNight Moon"
if command -v fish &> /dev/null; then
    fish -c "yes | fish_config theme save '$FISH_THEME'" 2>/dev/null && \
        log_info "已设置主题: 🎨 $FISH_THEME" || \
        log_warn "主题设置失败，请手动运行: fish_config theme save '$FISH_THEME'"
else
    log_warn "未检测到 Fish，跳过主题初始化"
fi

echo -e "\n${BOLD}==========================================
      ✅ 安装完成! 请重启终端生效
==========================================${NC}"
