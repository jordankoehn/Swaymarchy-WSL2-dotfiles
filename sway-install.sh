#!/bin/bash

username="$(logname)"
username=${username:-$SUDO_USER}

# Check for sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Install the custom package list
echo "Installing needed packages..."
# Check if the os-release file exists
if [ -f /etc/os-release ]; then
    # Source the file to load the $ID variable
    . /etc/os-release

    case "$ID" in
    debian)
        echo "Detected Debian."
        apt install $(grep -vE '^#' packages-repository_debian.txt)
        ./install-awesome-terminal-font.sh
        ./install-fonts-ext.sh
        ./install-nwg.sh
        ./install-qogir.sh
        ./install-walker.sh
        ./install-vicinae.sh
        ;;
    ubuntu)
        echo "Detected Ubuntu."
        echo "untested" >&2
        exit 1
        ;;
    arch)
        echo "Detected Arch Linux."
        pacman -S --noconfirm --noprogressbar --needed --disable-download-timeout $(grep -v '^#' packages-repository.txt)
        ;;
    *)
        echo "Current distribution ($ID) is not explicitly supported."
        ;;
    esac
else
    echo "Critical: Could not determine the Linux distribution (/etc/os-release missing)."
    exit 1
fi

# Deploy user configs
echo "Deploying user configs..."
rsync -a .config "/home/${username}/"
rsync -a .local "/home/${username}/"
rsync -a home_config/ "/home/${username}/"
# Restore user ownership
chown -R "${username}:${username}" "/home/${username}"

# Deploy system configs
echo "Deploying system configs..."
rsync -a --chown=root:root etc/ /etc/

# Remove the repo
echo "Removing the EOS Community Sway repo..."
rm -rf ../sway

# Install sway-wsl2
git clone https://github.com/jordankoehn/sway-wsl2.git /tmp/sway-wsl2
cd /tmp/sway-wsl2
./install.sh

# Leverage omarchy themes
git clone --branch v3.8.1 https://github.com/basecamp/omarchy.git ~/.local/share/omarchy
echo 'source $HOME/.local/share/omarchy/default/bash/rc' >>~/.bashrc
source ~/.bashrc
mkdir -p /home/dev/.config/omarchy/theme

username=$USER
omarchy_configs=("btop" "chromium" "fontconfig" "foot" "git" "ghostty" "kitty" "lazygit" "omarchy" "tmux" "chromium-flags.conf")
for _path in "${omarchy_configs[@]}"; do
    _source_path=$OMARCHY_PATH/config/$_path
    if [[ -d $_source_path ]]; then
        rsync -a $_source_path/ "/home/${username}/.config/$_path/"
    else
        rsync -a $_source_path "/home/${username}/.config/$_path"
    fi
done

mkdir -p ~/.config/environment.d
echo "MOZ_ENABLE_WAYLAND=1" >~/.config/environment.d/omarchy-firefox-wayland.conf
cp -f "$OMARCHY_PATH/default/firefox/policies.json" "/usr/lib/firefox/distribution/policies.json"
cat << EOF > "/home/${username}/.config/elephant/symbols.toml"
command = 'wl-copy && swaymsg exec "wtype -M shift -k Insert -m shift"'
EOF
# Restore user ownership
chown -R "${username}:${username}" "/home/${username}"

echo "Installation complete."
