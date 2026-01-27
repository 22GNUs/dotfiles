#!/bin/bash

# OpenCode Configuration Setup Script
# Repository: https://github.com/22GNUs/opencode_config.git

REPO_URL="https://github.com/22GNUs/opencode_config.git"
CONFIG_DIR="$HOME/.config/opencode"
BACKUP_DIR="$HOME/.config/opencode_backup_$(date +%Y%m%d_%H%M%S)"
CACHE_PKG_JSON="$HOME/.cache/opencode/package.json"
REQUIRED_JAVA_VERSION=21

echo "🚀 Starting OpenCode configuration setup..."

# ------------------------------------------------------------------
# 1. Plugin Cleanup (@plannotator/opencode)
# ------------------------------------------------------------------
echo ""
echo "🧹 Cleaning plugin cache..."

PLUGIN_NAME="@plannotator/opencode"
PLUGIN_DIR="$HOME/.cache/opencode/node_modules/$PLUGIN_NAME"

if [ -d "$PLUGIN_DIR" ]; then
  echo "   - Removing cached plugin directory..."
  rm -rf "$PLUGIN_DIR"
fi

echo "   ✅ Plugin cache cleared."
echo ""
echo "📦 Plugin will be auto-installed: $PLUGIN_NAME@latest"
echo "   - Intelligent code annotation generation"

# ------------------------------------------------------------------
# 2. JDTLS + Lombok Setup (Download)
# ------------------------------------------------------------------
echo ""
echo "☕ Setting up JDTLS + Lombok support..."

LIB_DIR="$CONFIG_DIR/lib"
LOMBOK_JAR="$LIB_DIR/lombok.jar"

mkdir -p "$LIB_DIR"

if [ ! -f "$LOMBOK_JAR" ]; then
  echo "   - Downloading lombok.jar..."
  curl -sL https://projectlombok.org/downloads/lombok.jar -o "$LOMBOK_JAR"
  if [ $? -eq 0 ]; then
    echo "   ✅ lombok.jar downloaded to $LIB_DIR/"
  else
    echo "   ❌ Failed to download lombok.jar."
  fi
else
  echo "   ✅ lombok.jar already exists."
fi

# ------------------------------------------------------------------
# 3. Environment & Dependency Checks
# ------------------------------------------------------------------
echo ""
echo "🔍 Checking environment & dependencies..."

MISSING_ITEMS=()

# Check Java version
if command -v java &>/dev/null; then
  # Filter out "Picked up JAVA_TOOL_OPTIONS" line from java -version output
  JAVA_VERSION=$(java -version 2>&1 | grep -v "Picked up" | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
  if [ "$JAVA_VERSION" -ge "$REQUIRED_JAVA_VERSION" ] 2>/dev/null; then
    echo "   ✅ Java $JAVA_VERSION (required: $REQUIRED_JAVA_VERSION+)"
  else
    echo "   ❌ Java $JAVA_VERSION (required: $REQUIRED_JAVA_VERSION+)"
    MISSING_ITEMS+=("Java $REQUIRED_JAVA_VERSION+")
  fi
else
  echo "   ❌ Java not found (required: $REQUIRED_JAVA_VERSION+)"
  MISSING_ITEMS+=("Java $REQUIRED_JAVA_VERSION+")
fi

# Check JAVA_TOOL_OPTIONS
EXPECTED_LOMBOK_PATH=".config/opencode/lib/lombok.jar"
if [ -n "$JAVA_TOOL_OPTIONS" ] && [[ "$JAVA_TOOL_OPTIONS" == *"$EXPECTED_LOMBOK_PATH"* ]]; then
  echo "   ✅ JAVA_TOOL_OPTIONS"
else
  echo "   ❌ JAVA_TOOL_OPTIONS"
  MISSING_ITEMS+=("JAVA_TOOL_OPTIONS")
fi

# Check CONTEXT7_API_KEY
if [ -n "$CONTEXT7_API_KEY" ]; then
  echo "   ✅ CONTEXT7_API_KEY"
else
  echo "   ❌ CONTEXT7_API_KEY"
  MISSING_ITEMS+=("CONTEXT7_API_KEY")
fi

# Check CLOUDFLARE_API_TOKEN
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
  echo "   ✅ CLOUDFLARE_API_TOKEN"
else
  echo "   ❌ CLOUDFLARE_API_TOKEN"
  MISSING_ITEMS+=("CLOUDFLARE_API_TOKEN")
fi

# Check CLOUDFLARE_GATEWAY_ID
if [ -n "$CLOUDFLARE_GATEWAY_ID" ]; then
  echo "   ✅ CLOUDFLARE_GATEWAY_ID"
else
  echo "   ❌ CLOUDFLARE_GATEWAY_ID"
  MISSING_ITEMS+=("CLOUDFLARE_GATEWAY_ID")
fi

# Check CLOUDFLARE_ACCOUNT_ID
if [ -n "$CLOUDFLARE_ACCOUNT_ID" ]; then
  echo "   ✅ CLOUDFLARE_ACCOUNT_ID"
else
  echo "   ❌ CLOUDFLARE_ACCOUNT_ID"
  MISSING_ITEMS+=("CLOUDFLARE_ACCOUNT_ID")
fi

# ------------------------------------------------------------------
# 5. Summary
# ------------------------------------------------------------------
echo ""
echo "🎉 Setup complete!"
echo "Configuration is located at: $CONFIG_DIR"

if [ ${#MISSING_ITEMS[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  ACTION REQUIRED - Missing items:"
  for item in "${MISSING_ITEMS[@]}"; do
    echo "   • $item"
  done
  echo ""
  echo "To fix, add the following to your shell configuration:"
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

echo ""
echo "📝 Next steps:"
echo "   1. Test your setup:"
echo "      opencode run \"Hello\""
echo ""
echo "   2. Restart OpenCode to apply all changes."
