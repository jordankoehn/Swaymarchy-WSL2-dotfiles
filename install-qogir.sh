#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

REPO_URL="https://github.com/vinceliuice/Qogir-icon-theme.git"
CLONE_DIR="/tmp/Qogir-icon-theme"

echo "🚀 Starting Qoqir icons installation..."

# Clone the repository to /tmp
echo "📥 Cloning repository to $CLONE_DIR..."
rm -rf "$CLONE_DIR"
git clone --depth 1 "$REPO_URL" "$CLONE_DIR"
cd "$CLONE_DIR"
./install.sh

cd ~

# Cleanup
echo "Cleaning up..."
rm -rf "$CLONE_DIR"