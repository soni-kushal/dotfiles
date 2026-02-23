#!/usr/bin/env bash

OPTIONS="\
Performance
Balanced
Power Saver
Charge up to 90% (temporary)
Reset charge threshold to 70%
"

CHOICE=$(echo -e "$OPTIONS" | fuzzel --dmenu --prompt "Power Options:" --lines=5 --width=30)

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
	"Charge up to 90% (temporary)")
		pkexec tlp setcharge 85 90
		notify-send "Power Management" "Charging temporarily allowed up to 90%"
		;;
	"Reset charge threshold to 70%")
		pkexec tlp setcharge
		notify-send "Power Management" "Charging limit reset to 70%"
		;;
	*)
	exit 0
	;;
esac
