#!/usr/bin/env bash

# Power options menu - detects whether the machine uses asusctl or tlp
# and runs the matching commands, so one script works on both machines.

# Limit restored by the "Reset charge limit" entry (asusctl branch only;
# asusctl has no stored-default reset). The tlp branch instead applies the
# configured default itself via "tlp setcharge".
ASUSCTL_RESET_LIMIT=60

# --- detect power management backend ----------------------------------------
if command -v asusctl >/dev/null 2>&1 &&
	{ systemctl is-active --quiet asusd 2>/dev/null || pgrep -x asusd >/dev/null 2>&1; }
then
	BACKEND="asusctl"
elif command -v tlpctl >/dev/null 2>&1 || command -v tlp >/dev/null 2>&1; then
	BACKEND="tlp"
else
	notify-send "Power Options" "Neither asusctl nor tlp available"
	exit 1
fi

if [ "$BACKEND" = asusctl ]; then
	OPTIONS="\
Performance
Balanced
Power Saver
Charge to full capacity (temporary)
Reset charge limit to ${ASUSCTL_RESET_LIMIT}%
"
else
	OPTIONS="\
Performance
Balanced
Power Saver
Charge to full capacity (temporary)
Reset charge threshold to 75%
"
fi

CHOICE=$(echo -e "$OPTIONS" | fuzzel --dmenu --prompt "Power Options:" --lines=5 --width=35)

# Run a command; on failure show a notification and stop (no success toast).
run() {
	if ! "$@"; then
		notify-send "Power Options" "Command failed: $*"
		exit 1
	fi
}

case "$BACKEND" in
asusctl)
	case "$CHOICE" in
		Performance)
			run asusctl profile set Performance
			notify-send "Power Profile:" "Performance profile enabled"
			;;
		Balanced)
			run asusctl profile set Balanced
			notify-send "Power Profile:" "Balanced profile enabled"
			;;
		"Power Saver")
			run asusctl profile set Quiet
			notify-send "Power Profile:" "Power saver profile enabled"
			;;
		"Charge to full capacity (temporary)")
			# One-shot charge to 100%, limit restored automatically afterwards
			run asusctl battery oneshot
			notify-send "Power Management" "Charging temporarily to full capacity"
			;;
		"Reset charge limit to ${ASUSCTL_RESET_LIMIT}%")
			run asusctl battery limit "$ASUSCTL_RESET_LIMIT"
			notify-send "Power Management" "Charging limit reset to ${ASUSCTL_RESET_LIMIT}%"
			;;
		*)
			exit 0
			;;
	esac
	;;
tlp)
	case "$CHOICE" in
		Performance)
			run tlpctl set performance
			notify-send "Power Profile:" "Performance profile enabled"
			;;
		Balanced)
			run tlpctl set balanced
			notify-send "Power Profile:" "Balanced profile enabled"
			;;
		"Power Saver")
			run tlpctl set power-saver
			notify-send "Power Profile:" "Power saver profile enabled"
			;;
		"Charge to full capacity (temporary)")
			run pkexec tlp setcharge 90 95
			notify-send "Power Management" "Charging temporarily allowed to 95%"
			;;
		"Reset charge threshold to 75%")
			run pkexec tlp setcharge
			notify-send "Power Management" "Charging limit reset to 75%"
			;;
		*)
			exit 0
			;;
	esac
	;;
esac
