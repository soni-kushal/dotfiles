##!/bin/bash

# 1. Identify Laptop and find the "other" output
LAPTOP="eDP-1"
EXTERNAL=$(niri msg outputs | grep "^Output" | grep -v "$LAPTOP" | sed -n 's/.*(\(.*\)).*/\1/p' | head -n 1)

# 2. Safety check: If EXTERNAL is empty, only show Laptop option or exit
if [ -z $EXTERNAL ]; then
    # Optional: notify-send "No external monitor found"
    OPTIONS="󰌢 Laptop Only"
else
    OPTIONS="󰌢 Laptop Only\n󰍹 External Only ($EXTERNAL)\n󰍺 Extend Displays"
fi

# 3. Launch Fuzzel
CHOICE=$(echo -e "$OPTIONS" | fuzzel --dmenu -p "Display Setup: ")

# 4. Action Logic
case "$CHOICE" in
    "󰌢 Laptop Only")
        niri msg output $LAPTOP on
        niri msg output $EXTERNAL off
        ;;
    "󰍹 External Only ($EXTERNAL)")
        niri msg output $LAPTOP off
        niri msg output $EXTERNAL on
        ;;
    "󰍺 Extend Displays")
        niri msg output $LAPTOP on
        niri msg output $EXTERNAL on
        ;;
    *)
        exit 0
        ;;
esac
