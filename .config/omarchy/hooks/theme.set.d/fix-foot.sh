#!/bin/bash

if [ -f "/etc/debian_version" ]; then
  # Debian uses old format
  theme_ini=~/.config/omarchy/current/theme/foot.ini
  sed -i 's/colors-dark/colors/g' $theme_ini
  sed -i '/cursor/ s/^/#/' $theme_ini
fi