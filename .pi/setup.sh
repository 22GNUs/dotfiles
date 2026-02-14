#!/bin/bash

# Pi Agent Configuration Setup Script
set -e

# Get script directory (dotfiles root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

# Configuration
AGENT_STUFF_REPO="git@github.com:mitsuhiko/agent-stuff.git"
EXTERNAL_DIR="$SCRIPT_DIR/external"
AGENT_STUFF_DIR="$EXTERNAL_DIR/agent-stuff"
PI_EXTENSIONS_DIR="$SCRIPT_DIR/.pi/agent/extensions"

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# Logging Functions
# ============================================================================
log_info() { echo -e "${GREEN}✅${NC} $1"; }
log_step() { echo -e "${BLUE}🚀${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️${NC} $1"; }
log_error() { echo -e "${RED}❌${NC} $1"; }

# ============================================================================
# Validation Functions
# ============================================================================

validate_git_repo() {
  local dir=$1
  if [ -d "$dir/.git" ]; then
    echo 0
  else
    echo 1
  fi
}

validate_symlink() {
  local link=$1
  if [ -L "$link" ] && [ -e "$link" ]; then
    echo 0
  else
    echo 1
  fi
}

# ============================================================================
# Setup Functions
# ============================================================================

setup_external_repo() {
  local repo_url=$1
  local target_dir=$2
  local repo_name=$(basename "$target_dir")

  log_step "Setting up external repository: $repo_name"

  if [ -d "$target_dir" ]; then
    if [ "$(validate_git_repo "$target_dir")" -eq 0 ]; then
      log_info "Repository exists, pulling latest changes..."
      (cd "$target_dir" && git pull)
    else
      log_warn "Directory exists but is not a git repo: $target_dir"
      log_info "Backing up to ${target_dir}.backup.$(date +%Y%m%d_%H%M%S)"
      mv "$target_dir" "${target_dir}.backup.$(date +%Y%m%d_%H%M%S)"
      log_info "Cloning $repo_name..."
      git clone "$repo_url" "$target_dir"
    fi
  else
    log_info "Cloning $repo_name..."
    mkdir -p "$(dirname "$target_dir")"
    git clone "$repo_url" "$target_dir"
  fi
}

setup_extensions() {
  log_step "Setting up Pi extensions..."

  local extensions=(
    "answer.ts"
    "todos.ts"
  )

  mkdir -p "$PI_EXTENSIONS_DIR"

  for ext in "${extensions[@]}"; do
    local source="$AGENT_STUFF_DIR/pi-extensions/$ext"
    local target="$PI_EXTENSIONS_DIR/$ext"

    if [ ! -f "$source" ]; then
      log_error "Extension source not found: $source"
      continue
    fi

    if [ -L "$target" ]; then
      log_info "Updating symlink: $ext"
      rm "$target"
    elif [ -f "$target" ]; then
      log_warn "Backing up existing file: $ext"
      mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    ln -sf "$source" "$target"
    log_info "Linked: $ext -> external/agent-stuff/pi-extensions/$ext"
  done
}

# ============================================================================
# Validation Mode
# ============================================================================

run_validation() {
  echo ""
  log_step "Running validation checks..."
  echo ""

  local missing_items=()
  local all_good=true

  # 1. Check external repo
  echo -e "${BOLD}External Repositories:${NC}"
  if [ "$(validate_git_repo "$AGENT_STUFF_DIR")" -eq 0 ]; then
    log_info "agent-stuff: $(cd "$AGENT_STUFF_DIR" && git rev-parse --short HEAD)"
  else
    log_error "agent-stuff: Not a valid git repository"
    missing_items+=("agent-stuff repository")
    all_good=false
  fi
  echo ""

  # 2. Check extensions
  echo -e "${BOLD}Extensions:${NC}"
  local extensions=(
    "answer.ts"
    "todos.ts"
  )

  for ext in "${extensions[@]}"; do
    local target="$PI_EXTENSIONS_DIR/$ext"
    if [ "$(validate_symlink "$target")" -eq 0 ]; then
      log_info "$ext: $(readlink "$target" | sed 's|.*external/|external/|')"
    else
      log_error "$ext: Not linked"
      missing_items+=("$ext extension")
      all_good=false
    fi
  done
  echo ""

  # Summary
  if [ "$all_good" = true ]; then
    echo -e "${GREEN}${BOLD}✅ All checks passed!${NC}"
    return 0
  else
    echo -e "${YELLOW}${BOLD}⚠️  Issues found:${NC}"
    for item in "${missing_items[@]}"; do
      echo -e "   • $item"
    done
    return 1
  fi
}

# ============================================================================
# Show Help
# ============================================================================

show_help() {
  echo -e "${BOLD}Pi Agent Setup Script${NC}"
  echo ""
  echo -e "${BOLD}Usage:${NC}"
  echo "  ./setup.sh [options]"
  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo "  -v, --validate    Run validation checks only (no setup)"
  echo "  -h, --help        Show this help message"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo "  ./setup.sh              # Run full setup"
  echo "  ./setup.sh --validate   # Check configuration status"
  echo ""
  echo -e "${BOLD}External Repositories:${NC}"
  echo "  • agent-stuff -> $AGENT_STUFF_REPO"
  echo ""
  echo -e "${BOLD}Extensions:${NC}"
  echo "  • answer.ts - AI answer functionality"
  echo "  • todos.ts  - Todo management"
}

# ============================================================================
# Main
# ============================================================================

main() {
  local validate_only=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -v|--validate)
        validate_only=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        echo -e "${RED}Unknown option: $1${NC}"
        show_help
        exit 1
        ;;
    esac
  done

  if [ "$validate_only" = true ]; then
    run_validation
    exit $?
  fi

  # Full setup mode
  echo "🚀 Starting Pi Agent configuration setup..."
  echo ""

  # 1. Setup external repositories
  setup_external_repo "$AGENT_STUFF_REPO" "$AGENT_STUFF_DIR"
  echo ""

  # 2. Setup extensions
  setup_extensions
  echo ""

  # 3. Run validation
  if run_validation; then
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "📁 Configuration locations:"
    echo "   • External repo: $AGENT_STUFF_DIR"
    echo "   • Extensions: $PI_EXTENSIONS_DIR"
  else
    echo ""
    echo "⚠️  Setup completed with warnings. See above for details."
  fi
}

main "$@"
