#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
# Core binary installation directory
BIN_DIR="$HOME/.local/bin"

# Directory where Elephant plugins/providers should reside
PROVIDER_DIR="$HOME/.config/elephant/providers"

# Bash array containing Elephant core service and specific functional providers.
PLUGINS=(
    "elephant"
    "desktopapplications"
    "clipboard"
    "calc"
    "todo"
    "symbols"
    "websearch"
    "providerlist"
)

# Proactively ensure all targeted installation directories exist
mkdir -p "$BIN_DIR" "$PROVIDER_DIR"

# -----------------------------------------------------------------------------
# Installation Execution
# -----------------------------------------------------------------------------
echo "📦 Preparing isolated temporary workspace..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR"

echo "🌐 Fetching latest Walker release..."
WALKER_API_URL="https://api.github.com/repos/abenz1267/walker/releases/latest"
WALKER_DOWNLOAD_URL=$(curl -s "$WALKER_API_URL" | jq -r '.assets[] | select(.name | endswith("x86_64-unknown-linux-gnu.tar.gz")) | .browser_download_url')

if [[ -z "$WALKER_DOWNLOAD_URL" || "$WALKER_DOWNLOAD_URL" == "null" ]]; then
    echo "❌ Error: Could not resolve Walker binary asset via jq query." >&2
    exit 1
fi

echo "⬇️ Downloading Walker..."
curl -L -o "walker.tar.gz" "$WALKER_DOWNLOAD_URL"

echo "📂 Extracting Walker..."
tar -xzf "walker.tar.gz"
find . -maxdepth 2 -type f -name "walker" -exec mv {} "$BIN_DIR/" \;
chmod +x "$BIN_DIR/walker"
echo "✅ Installed: walker -> $BIN_DIR/walker"

echo "🌐 Fetching latest Elephant release specifications..."
ELEPHANT_API_URL="https://api.github.com/repos/abenz1267/elephant/releases/latest"
ELEPHANT_DATA=$(curl -s "$ELEPHANT_API_URL")

for plugin in "${PLUGINS[@]}"; do
    # Route core 'elephant' to bin, and plugins/providers to configuration path
    if [[ "$plugin" == "elephant" ]]; then
        # # uwsm can't find .local/bin it on the path, so I give up
        TARGET_DEST=/usr/local/bin
    else
        TARGET_DEST="$PROVIDER_DIR"
    fi

    echo "⚙️ Processing Elephant component: $plugin"
    
    # Use jq to securely match the exact plugin archive name
    TARGET_ASSET="${plugin}-linux-amd64.tar.gz"
    PLUGIN_URL=$(echo "$ELEPHANT_DATA" | jq -r --arg asset "$TARGET_ASSET" '.assets[] | select(.name == $asset) | .browser_download_url')
    
    if [[ -z "$PLUGIN_URL" || "$PLUGIN_URL" == "null" ]]; then
        echo "⚠️  Warning: No release asset found matching '$TARGET_ASSET'. Skipping..."
        continue
    fi
    
    echo "  ⬇️ Downloading $plugin..."
    curl -L -o "${plugin}.tar.gz" "$PLUGIN_URL"
    
    echo "  📂 Extracting $plugin..."
    PLUGIN_TMP_DIR="${TMP_DIR}/extract_${plugin}"
    mkdir -p "$PLUGIN_TMP_DIR"
    tar -xzf "${plugin}.tar.gz" -C "$PLUGIN_TMP_DIR"
    
    # Process, strip the target architecture suffix, and move to final home
    find "$PLUGIN_TMP_DIR" -type f | while read -r file; do
        if [[ -f "$file" ]]; then
            chmod +x "$file"
            file_base=$(basename "$file")
            
            # Remove the architecture string from the final filename string
            clean_name="${file_base/-linux-amd64/}"
            
            if [[ "$plugin" == "elephant" ]]; then
                sudo mv "$file" "$TARGET_DEST/$clean_name"
            else
                mv "$file" "$TARGET_DEST/$clean_name"
            fi
            echo "  ✅ Installed: $clean_name -> $TARGET_DEST/$clean_name"
        fi
    done
done

# Install libqalculate additional deps
runuser -u dev -- ./install-libqalculate.sh # calculator
apt install -y imagemagick # clipboard history

# -----------------------------------------------------------------------------
# Post-Installation Summary
# -----------------------------------------------------------------------------
echo "---"
echo "🎉 Installation Complete!"
echo "---"
echo "📂 Binaries target directory:  $BIN_DIR"
echo "📂 Providers target directory: $PROVIDER_DIR"
