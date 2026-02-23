#!/bin/bash

# Define the menu options
entries=" Power off\n Reboot\n Suspend\n󰗽 Logout\n󰷛 Lock"

# Use fuzzel in dmenu mode to pick an option
# You can customize the look here (width, lines, etc.)
selected=$(echo -e "$entries" | fuzzel --dmenu --prompt=" Power: " --lines=5 --width=20)

# Execute the command based on selection
case $selected in
    *"Power off")
        systemctl poweroff ;;
    *"Reboot")
        systemctl reboot ;;
    *"Suspend")
        systemctl suspend ;;
    *"Logout")
        # Command depends on your compositor (e.g., hyprctl dispatch exit or swaymsg exit)
        loginctl terminate-user $USER ;;
    *"Lock")
        # Replace with your lock command (swaylock, hyprlock, etc.)
        swaylock -c 191623;;
esac
