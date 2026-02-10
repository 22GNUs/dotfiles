#!/bin/bash

# OpenCode Configuration Setup Script
# Repository: https://github.com/22GNUs/opencode_config.git

set -e

REPO_URL="https://github.com/22GNUs/opencode_config.git"
CONFIG_DIR="$HOME/.config/opencode"
BACKUP_DIR="$HOME/.config/opencode_backup_$(date +%Y%m%d_%H%M%S)"
CACHE_PKG_JSON="$HOME/.cache/opencode/package.json"
REQUIRED_JAVA_VERSION=21

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
log_check() {
  local status=$1
  local name=$2
  local value=$3
  if [ "$status" -eq 0 ]; then
    echo -e "   ${GREEN}✅${NC} $name${value:+: $value}"
  else
    echo -e "   ${RED}❌${NC} $name"
  fi
}

# ============================================================================
# Validation Functions
# ============================================================================

# Check Java version
validate_java() {
  if command -v java &>/dev/null; then
    local version
    version=$(java -version 2>&1 | grep -v "Picked up" | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$version" -ge "$REQUIRED_JAVA_VERSION" ] 2>/dev/null; then
      echo 0
      echo "$version"
    else
      echo 1
    fi
  else
    echo 1
  fi
}

# Check environment variable
validate_env_var() {
  local var_name=$1
  local expected_value=$2
  local actual_value="${!var_name}"

  if [ -z "$actual_value" ]; then
    echo 1
  elif [ -n "$expected_value" ] && [[ "$actual_value" != *"$expected_value"* ]]; then
    echo 1
  else
    echo 0
  fi
}

# Check if file exists
validate_file() {
  local file=$1
  if [ -f "$file" ]; then
    echo 0
  else
    echo 1
  fi
}

# Check if symlink is valid
validate_symlink() {
  local link=$1
  if [ -L "$link" ] && [ -e "$link" ]; then
    echo 0
  else
    echo 1
  fi
}

# Check if directory is a valid git repo
validate_git_repo() {
  local dir=$1
  if [ -d "$dir/.git" ]; then
    echo 0
  else
    echo 1
  fi
}

# ============================================================================
# Setup Functions
# ============================================================================

setup_plugin_cache() {
  log_step "Cleaning plugin cache..."
  local plugin_name="@plannotator/opencode"
  local plugin_dir="$HOME/.cache/opencode/node_modules/$plugin_name"

  if [ -d "$plugin_dir" ]; then
    rm -rf "$plugin_dir"
    log_info "Plugin cache cleared"
  else
    log_info "No plugin cache to clean"
  fi
  echo ""
  echo "📦 Plugin will be auto-installed: $plugin_name@latest"
  echo "   - Intelligent code annotation generation"
}

setup_lombok() {
  log_step "Setting up JDTLS + Lombok support..."
  local lib_dir="$CONFIG_DIR/lib"
  local lombok_jar="$lib_dir/lombok.jar"

  mkdir -p "$lib_dir"

  if [ ! -f "$lombok_jar" ]; then
    echo "   - Downloading lombok.jar..."
    if curl -sL https://projectlombok.org/downloads/lombok.jar -o "$lombok_jar"; then
      log_info "lombok.jar downloaded to $lib_dir/"
    else
      log_error "Failed to download lombok.jar"
    fi
  else
    log_info "lombok.jar already exists"
  fi
}

# ============================================================================
# Validation Mode
# ============================================================================

run_validation() {
  echo ""
  log_step "Running validation checks..."
  echo ""

  local missing_items=()
  local warnings=()

  # 1. Check Java
  echo -e "${BOLD}Java:${NC}"
  local java_status
  java_status=$(validate_java)
  if [ "$java_status" = "0" ] || [ -z "$java_status" ]; then
    local java_version
    java_version=$(java -version 2>&1 | grep -v "Picked up" | head -1 | cut -d'"' -f2)
    log_check 0 "Java version" "$java_version (>= $REQUIRED_JAVA_VERSION)"
  else
    log_check 1 "Java version" "(required: $REQUIRED_JAVA_VERSION+)"
    missing_items+=("Java $REQUIRED_JAVA_VERSION+")
  fi

  echo ""

  # 2. Check Lombok
  echo -e "${BOLD}Lombok:${NC}"
  local lombok_status
  lombok_status=$(validate_file "$CONFIG_DIR/lib/lombok.jar")
  log_check "$lombok_status" "lombok.jar"
  [ "$lombok_status" -ne 0 ] && missing_items+=("lombok.jar")

  echo ""

  # 3. Check Environment Variables
  echo -e "${BOLD}Environment Variables:${NC}"

  local java_opts_status
  java_opts_status=$(validate_env_var "JAVA_TOOL_OPTIONS" ".config/opencode/lib/lombok.jar")
  log_check "$java_opts_status" "JAVA_TOOL_OPTIONS"
  [ "$java_opts_status" -ne 0 ] && missing_items+=("JAVA_TOOL_OPTIONS")

  local c7_status
  c7_status=$(validate_env_var "CONTEXT7_API_KEY")
  log_check "$c7_status" "CONTEXT7_API_KEY"
  [ "$c7_status" -ne 0 ] && missing_items+=("CONTEXT7_API_KEY")

  local cf_token_status
  cf_token_status=$(validate_env_var "CLOUDFLARE_API_TOKEN")
  log_check "$cf_token_status" "CLOUDFLARE_API_TOKEN"
  [ "$cf_token_status" -ne 0 ] && missing_items+=("CLOUDFLARE_API_TOKEN")

  local cf_gateway_status
  cf_gateway_status=$(validate_env_var "CLOUDFLARE_GATEWAY_ID")
  log_check "$cf_gateway_status" "CLOUDFLARE_GATEWAY_ID"
  [ "$cf_gateway_status" -ne 0 ] && missing_items+=("CLOUDFLARE_GATEWAY_ID")

  local cf_account_status
  cf_account_status=$(validate_env_var "CLOUDFLARE_ACCOUNT_ID")
  log_check "$cf_account_status" "CLOUDFLARE_ACCOUNT_ID"
  [ "$cf_account_status" -ne 0 ] && missing_items+=("CLOUDFLARE_ACCOUNT_ID")

  # Summary
  echo ""
  if [ ${#missing_items[@]} -eq 0 ]; then
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
  echo -e "${BOLD}OpenCode Setup Script${NC}"
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
  echo "🚀 Starting OpenCode configuration setup..."
  echo ""

  # 1. Plugin Cache
  setup_plugin_cache

  # 2. Lombok
  setup_lombok

  # 3. Run validation at the end
  echo ""
  if run_validation; then
    echo ""
    echo "🎉 Setup complete! Configuration is located at: $CONFIG_DIR"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Test your setup:"
    echo "      opencode run \"Hello\""
    echo ""
    echo "   2. Restart OpenCode to apply all changes."
  else
    echo ""
    echo "⚠️  Setup completed with warnings. See above for details."
    echo ""
    echo "To fix environment variables, add to your shell config:"
    echo ""
    echo "  Fish:"
    echo "    set -Ux JAVA_TOOL_OPTIONS \"-javaagent:\$HOME/.config/opencode/lib/lombok.jar\""
    echo "    set -Ux CONTEXT7_API_KEY \"your_key_here\""
    echo "    set -Ux CLOUDFLARE_API_TOKEN \"your_token_here\""
    echo "    set -Ux CLOUDFLARE_GATEWAY_ID \"your_gateway_id_here\""
    echo "    set -Ux CLOUDFLARE_ACCOUNT_ID \"your_account_id_here\""
    echo ""
    echo "  Bash/Zsh:"
    echo "    export JAVA_TOOL_OPTIONS=\"-javaagent:\$HOME/.config/opencode/lib/lombok.jar\""
    echo "    export CONTEXT7_API_KEY=\"your_key_here\""
    echo "    export CLOUDFLARE_API_TOKEN=\"your_token_here\""
    echo "    export CLOUDFLARE_GATEWAY_ID=\"your_gateway_id_here\""
    echo "    export CLOUDFLARE_ACCOUNT_ID=\"your_account_id_here\""
  fi
}

main "$@"
