#!/bin/bash

MENU="$(printf "󰩈 Exit\n󰐥 Shutdown")"
LINE_COUNT="$(printf '%s' "$MENU" | grep -c .)"

SELECTION="$(printf "$MENU" | omarchy-launch-walker --dmenu --width 295 --minheight 1 --maxheight 630 -p "Select an option: ")"

confirm_action() {
    local action="$1"
    CONFIRMATION="$(printf "No\nYes" | omarchy-launch-walker --dmenu --width 295 --minheight 1 --maxheight 630 -p "$action?")"
    [[ "$CONFIRMATION" == *"Yes"* ]]
}

case $SELECTION in
    *"󰩈 Exit"*)
        if confirm_action "Exit"; then
            swaymsg exit
        fi;;
    *"󰐥 Shutdown"*)
        if confirm_action "Shutdown"; then
            wsl.exe --shutdown
        fi;;
esac
