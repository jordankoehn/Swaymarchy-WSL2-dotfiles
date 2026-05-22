#!/bin/bash

# Exit on error
set -e

# Create local font directory if it doesn't exist
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

echo "Checking dependencies..."
sudo apt update && sudo apt install -y wget unzip fontconfig

# 1. JetBrains Mono
echo "Installing JetBrains Mono..."
JB_VERSION=$(wget -qO- "https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")')
wget -O /tmp/jb-mono.zip "https://github.com/JetBrains/JetBrainsMono/releases/download/v${JB_VERSION}/JetBrainsMono-${JB_VERSION}.zip"
unzip -o /tmp/jb-mono.zip "fonts/ttf/*" -d "$FONT_DIR"

# 2. Ubuntu Font Family
echo "Installing Ubuntu Font Family..."
UF_VERSION=$(wget -qO- "https://api.github.com/repos/canonical/Ubuntu-Sans-fonts/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")')
wget -O /tmp/ubuntu-font.zip "https://github.com/canonical/Ubuntu-Sans-fonts/releases/download/v${UF_VERSION}/UbuntuSans-fonts-${UF_VERSION}.zip"
unzip -o /tmp/ubuntu-font.zip -d /tmp/
cp /tmp/UbuntuSans-fonts-${UF_VERSION}/ttf/*.ttf "$FONT_DIR"

# 3. Nerd fonts
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts
cd /tmp/nerd-fonts
./install.sh
cd ~

# Cleanup and Refresh
echo "Cleaning up and updating font cache..."
rm /tmp/jb-mono.zip /tmp/ubuntu-font.zip
rm -rf /tmp/nerd-fonts/
fc-cache -fv

echo "Done! Fonts installed to $FONT_DIR"