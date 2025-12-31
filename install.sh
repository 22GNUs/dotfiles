#!/bin/bash

# Install dotfiles from repository to user directory
# Usage: ./install.sh [options]

set -e

# Color definitions
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

# Show usage
show_usage() {
    echo -e "${BOLD}Usage:${NC}"
    echo -e "    ./install.sh [options]"
    echo -e ""
    echo -e "${BOLD}Description:${NC}"
    echo -e "    Install dotfiles from repository to user directory via symlinks"
    echo -e ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "    -d, --install-deps    Check and install system dependencies (fonts, tmux theme deps, etc.)"
    echo -e "    -h, --help            Show this help message"
    echo -e ""
    echo -e "${BOLD}Examples:${NC}"
    echo -e "    ./install.sh                # Create symlinks only"
    echo -e "    ./install.sh -d             # Create symlinks and install dependencies"
    echo -e "    ./install.sh --install-deps # Same as above"
    echo -e ""
    echo -e "${BOLD}Dependencies:${NC}"
    echo -e "    Fonts:"
    echo -e "      - font-fantasque-sans-mono-nerd-font"
    echo -e "      - font-monaspace-nerd-font"
    echo -e "      - font-noto-sans-symbols-2"
    echo -e ""
    echo -e "    Tmux Tokyo-Night Theme:"
    echo -e "      - bash, bc, coreutils, gawk"
    echo -e "      - gh, glab, gsed, jq"
    echo -e "      - nowplaying-cli (macOS)"
    echo -e ""
}

# Parse command line arguments
INSTALL_DEPS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--install-deps)
            INSTALL_DEPS=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown parameter: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
done

# Define sync directories
# Format: "source_path(repo)|dest_path(user)|description"
SYNC_DIRS=(
    ".config/fish|$HOME/.config/fish|🐟 Fish config"
    ".config/ghostty|$HOME/.config/ghostty|👻 Ghostty config"
    ".config/zellij|$HOME/.config/zellij|🗄️ Zellij config"
    ".config/aerospace|$HOME/.config/aerospace|🚀 AeroSpace config"
    ".config/nvim|$HOME/.config/nvim|📝 Neovim config"
    ".config/opencode|$HOME/.config/opencode|🤖 OpenCode config"
)

# Define sync files
# Format: "source_path(repo)|dest_path(user)|description"
SYNC_FILES=(
    ".config/starship.toml|$HOME/.config/starship.toml|🚀 Starship config"
    ".gemini/GEMINI.md|$HOME/.gemini/GEMINI.md|🤖 Gemini config"
    ".ideavimrc|$HOME/.ideavimrc|⌨️  IDEA Vim config"
    ".tmux.conf|$HOME/.tmux.conf|🖥️  Tmux config"
)

echo -e "${BOLD}=========================================="
echo -e "      🔗 Dotfiles Installer (Repo -> Home)"
echo -e "==========================================${NC}"

# Get repository root absolute path
DOTFILES_ROOT=$(pwd)

# Create backup directory
mkdir -p "$BACKUP_DIR"
log_info "Conflicts will be backed up to: $BACKUP_DIR"

# Common function to create symlinks
create_symlink() {
    local src_rel=$1
    local dest=$2
    local desc=$3
    local src="$DOTFILES_ROOT/$src_rel"

    if [[ ! -e "$src" ]]; then
        log_error "Error: Source not found in repo: $src"
        return
    fi

    if [[ -L "$dest" ]]; then
        local current_link
        current_link=$(readlink "$dest")
        if [[ "$current_link" == "$src" ]]; then
            log_info "Already linked: $desc"
            return
        fi
        # Remove symlink if pointing to wrong location
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        # Backup regular file or directory
        mkdir -p "$(dirname "$BACKUP_DIR/${dest#$HOME/}")"
        mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
        log_warn "Backed up existing config: $desc"
    fi

    # Create parent directory
    mkdir -p "$(dirname "$dest")"
    # Create symlink
    ln -s "$src" "$dest"
    log_info "Linked successfully: $desc"
}

# 1. Process directories
log_step "Creating directory symlinks..."
for item in "${SYNC_DIRS[@]}"; do
    IFS="|" read -r src dest desc <<< "$item"
    create_symlink "$src" "$dest" "$desc"
done

# 2. Process files
echo ""
log_step "Creating file symlinks..."
for item in "${SYNC_FILES[@]}"; do
    IFS="|" read -r src dest desc <<< "$item"
    create_symlink "$src" "$dest" "$desc"
done

echo -e "\n${BOLD}=========================================="
echo -e "      🎉 Symlinks created successfully!"
echo -e "==========================================${NC}"

# 3. Check and install dependencies (only when -d flag is specified)
if [ "$INSTALL_DEPS" = true ]; then
    # 3.1 Check and install font dependencies
    log_step "Checking font dependencies..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            log_warn "Homebrew not detected, skipping font installation"
        else
            # Ensure cask-fonts tap is added
            if ! brew tap | grep -q "homebrew/cask-fonts"; then
                log_info "Adding homebrew/cask-fonts tap..."
                brew tap homebrew/cask-fonts
            fi
            
            FONT_DEPS=("font-fantasque-sans-mono-nerd-font" "font-monaspace-nerd-font" "font-noto-sans-symbols-2")
            MISSING_FONTS=()
            
            for font in "${FONT_DEPS[@]}"; do
                if ! brew list --cask "$font" &> /dev/null; then
                    MISSING_FONTS+=("$font")
                fi
            done
            
            if [ ${#MISSING_FONTS[@]} -eq 0 ]; then
                log_info "All font dependencies installed ✅"
            else
                log_warn "Missing fonts: ${MISSING_FONTS[*]}"
                read -p "Install now? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Installing: ${MISSING_FONTS[*]}"
                    brew install --cask "${MISSING_FONTS[@]}" && \
                        log_info "Fonts installed successfully ✅" || \
                        log_error "Some fonts failed to install"
                fi
            fi
        fi
    else
        log_warn "Non-macOS system, please install Nerd Fonts manually"
    fi

    # 3.2 Check and install Tmux Tokyo-Night theme dependencies
    log_step "Checking Tmux Tokyo-Night theme dependencies..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            log_warn "Homebrew not detected, skipping dependency installation"
        else
            TMUX_DEPS=("bash" "bc" "coreutils" "gawk" "gh" "glab" "gsed" "jq" "nowplaying-cli")
            MISSING_DEPS=()
            
            for dep in "${TMUX_DEPS[@]}"; do
                if ! brew list "$dep" &> /dev/null; then
                    MISSING_DEPS+=("$dep")
                fi
            done
            
            if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
                log_info "All Tmux dependencies installed ✅"
            else
                log_warn "Missing dependencies: ${MISSING_DEPS[*]}"
                read -p "Install now? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Installing: ${MISSING_DEPS[*]}"
                    brew install "${MISSING_DEPS[@]}" && \
                        log_info "Dependencies installed successfully ✅" || \
                        log_error "Some dependencies failed to install"
                fi
            fi
        fi
    else
        log_warn "Non-macOS system, please install Tmux theme dependencies manually"
    fi
else
    log_info "Skipping dependency check (use -d flag to enable)"
fi

# 4. Initialize Fish theme
log_step "Initializing Fish theme..."
FISH_THEME="TokyoNight Moon"
if command -v fish &> /dev/null; then
    fish -c "yes | fish_config theme save '$FISH_THEME'" 2>/dev/null && \
        log_info "Theme set: 🎨 $FISH_THEME" || \
        log_warn "Failed to set theme, run manually: fish_config theme save '$FISH_THEME'"
else
    log_warn "Fish not detected, skipping theme initialization"
fi

echo -e "\n${BOLD}==========================================
      ✅ Installation complete! Restart your terminal
==========================================${NC}"
