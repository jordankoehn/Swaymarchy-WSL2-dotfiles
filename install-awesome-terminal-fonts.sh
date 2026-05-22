#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

REPO_URL="https://github.com/gabrielelana/awesome-terminal-fonts"
CLONE_DIR="/tmp/awesome-terminal-fonts"
FONT_DIR="$HOME/.local/share/fonts"

# Detect which shell configuration file to update
if [ -n "$ZSH_VERSION" ] || [ "${SHELL##*/}" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "${SHELL##*/}" = "bash" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.bashrc" # Default fallback
fi

echo "🚀 Starting Awesome Terminal Fonts installation..."

# 1. Clone the repository to /tmp
echo "📥 Cloning repository to $CLONE_DIR..."
rm -rf "$CLONE_DIR"
git clone --depth 1 "$REPO_URL" "$CLONE_DIR"
cd "$CLONE_DIR"

# 2. Create necessary directories
echo "📁 Creating font directory..."
mkdir -p "$FONT_DIR"

# 3. Copy fonts and font maps from ./build to ~/.fonts
echo "📦 Copying fonts and shell maps to $FONT_DIR..."
if [ -d "./build" ]; then
    cp ./build/* "$FONT_DIR/"
else
    echo "❌ Error: ./build directory not found in the repository."
    exit 1
fi

# 4. Refresh the font cache
echo "🔄 Updating font cache..."
if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -fv "$FONT_DIR"
else
    echo "⚠️ Warning: fc-cache not found. Skipping cache update."
fi

# 5. Add font maps sourcing to shell startup script
echo "✍️ Adding font maps to $SHELL_RC..."
SOURCE_LINE="for f in \$HOME/.local/share/fonts/*.sh; do [ -r \"\$f\" ] && . \"\$f\"; done"

# Check if the sourcing logic is already in the file to avoid duplicates
if grep -Fxq "$SOURCE_LINE" "$SHELL_RC" 2>/dev/null; then
    echo "ℹ️ Font maps sourcing already exists in $SHELL_RC"
else
    echo -e "\n# Awesome Terminal Fonts Maps\n$SOURCE_LINE" >> "$SHELL_RC"
    echo "✅ Successfully added to $SHELL_RC"
fi

# 6. Cleanup /tmp
echo "🧹 Cleaning up $CLONE_DIR..."
rm -rf "$CLONE_DIR"

echo "🎉 Installation complete! Please restart your terminal or run 'source $SHELL_RC' to apply changes."