#!/bin/bash

choice=$(echo -e "Shutdown\nReboot\nSuspend\nLogout" | wofi --dmenu --width 200 --height 150 --prompt "Power")

case "$choice" in
  Shutdown) systemctl poweroff ;;
  Reboot) systemctl reboot ;;
  Suspend) systemctl suspend ;;
  Logout) hyprctl dispatch exit ;;
esac
