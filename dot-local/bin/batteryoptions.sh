#!/usr/bin/env bash

OPTIONS="\
Performance
Balanced
Power Saver
Charge to full capacity (temporary)
Reset charge threshold to 80%
"

CHOICE=$(echo -e "$OPTIONS" | fuzzel --dmenu --prompt "Power Options:" --lines=5 --width=35)

case "$CHOICE" in
	Performance)
		tlpctl set performance
		notify-send "Power Profile:" "Performance profile enabled"
		;;
	Balanced)
		tlpctl set balanced
		notify-send "Power Profile:" "Balanced profile enabled"
		;;
	"Power Saver")
		tlpctl set power-saver
		notify-send "Power Profile:" "Power saver profile enabled"
		;;
	"Charge to full capacity (temporary)")
		pkexec tlp fullcharge
		notify-send "Power Management" "Charging temporarily allowed to full capacity%"
		;;
	"Reset charge threshold to 80%")
		pkexec tlp setcharge
		notify-send "Power Management" "Charging limit reset to 80%"
		;;
	*)
	exit 0
	;;
esac
