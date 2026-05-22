#!/bin/bash

username="$(logname)"
username=${username:-$USER}

# Check for sudo
if [ "$EUID" -eq 0 ]; then
  echo "This script must NOT be run with sudo."
  exit 1
fi

# Install sway-wsl2
git clone https://github.com/jordankoehn/sway-wsl2.git /tmp/sway-wsl2
cd /tmp/sway-wsl2
./install.sh

# Leverage omarchy themes
git clone --branch v3.8.1 https://github.com/basecamp/omarchy.git ~/.local/share/omarchy
echo 'export OMARCHY_PATH=$HOME/.local/share/omarchy' > ~/.bashrc
echo 'export PATH=$OMARCHY_PATH/bin:$PATH' > ~/.bashrc
source ~/.bashrc
mkdir -p /home/dev/.config/omarchy/theme
omarchy_configs=("btop" "chromium" "fontconfig" "foot" "git" "ghosty" "kitty" "lazygit" "omarchy" "tmux")
for dir in "${my_array[@]}"
do
  rsync -a .local "/home/${username}/"
done
for dir in ""

echo "Installation complete."

