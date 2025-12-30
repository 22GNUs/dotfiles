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
# 1. Repository Setup (Clone or Pull)
# ------------------------------------------------------------------
echo ""
if [ -d "$CONFIG_DIR" ]; then
    if [ -d "$CONFIG_DIR/.git" ]; then
        echo "🔄 OpenCode config is already a git repo. Pulling latest changes..."
        cd "$CONFIG_DIR" && git pull
    else
        echo "⚠️  Existing configuration found (not a git repo)."
        echo "📦 Backing up existing config to $BACKUP_DIR..."
        mv "$CONFIG_DIR" "$BACKUP_DIR"
        
        echo "⬇️  Cloning configuration repository..."
        git clone "$REPO_URL" "$CONFIG_DIR"
    fi
else
    echo "⬇️  Cloning configuration repository..."
    git clone "$REPO_URL" "$CONFIG_DIR"
fi

if [ $? -ne 0 ]; then
    echo "❌ Failed to clone or update repository. Please check your internet connection."
    exit 1
fi

# ------------------------------------------------------------------
# 2. Plugin Cleanup (opencode-antigravity-auth)
# ------------------------------------------------------------------
echo ""
echo "🧹 Cleaning plugin cache..."

PLUGIN_NAME="opencode-antigravity-auth"
PLUGIN_DIR="$HOME/.cache/opencode/node_modules/$PLUGIN_NAME"

if [ -f "$CACHE_PKG_JSON" ]; then
    echo "   - Removing '$PLUGIN_NAME' from package.json..."
    # Using -i.bak to be compatible with macOS sed
    sed -i.bak "/$PLUGIN_NAME/d" "$CACHE_PKG_JSON"
fi

if [ -d "$PLUGIN_DIR" ]; then
    echo "   - Removing cached plugin directory..."
    rm -rf "$PLUGIN_DIR"
fi

echo "   ✅ Plugin cache cleared."
echo ""
echo "📦 Plugin will be auto-installed: $PLUGIN_NAME@1.2.4"
echo "   - Google OAuth with multi-account load balancing"
echo "   - Dual quota pools (Antigravity + Gemini CLI)"
echo "   - Models: Gemini 3, Claude 4.5, GPT-OSS 120B"

# ------------------------------------------------------------------
# 3. JDTLS + Lombok Setup (Download)
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
# 4. Environment & Dependency Checks
# ------------------------------------------------------------------
echo ""
echo "🔍 Checking environment & dependencies..."

MISSING_ITEMS=()

# Check Java version
if command -v java &> /dev/null; then
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
    echo ""
    echo "  Bash/Zsh:"
    echo "    export JAVA_TOOL_OPTIONS=\"-javaagent:\$HOME/.config/opencode/lib/lombok.jar\""
    echo "    export CONTEXT7_API_KEY=\"your_key_here\""
fi

echo ""
echo "📝 Next steps:"
echo "   1. Authenticate with Google for Antigravity models:"
echo "      opencode auth login"
echo "      → Select: Google → OAuth with Google (Antigravity)"
echo "      → Press Enter to skip Project ID"
echo "      → Complete sign-in in browser"
echo ""
echo "   2. Test your setup:"
echo "      opencode run \"Hello\" --model=google/gemini-3-pro-high"
echo ""
echo "   3. Restart OpenCode to apply all changes."
