#!/bin/bash

# Detect if an external monitor supporting DDC is connected
# We look for a display that isn't the primary laptop screen (usually display 1)
CHECK=$(ddcutil getvcp 10 --brief 2>/dev/null)

if [ $? -ne 0 ]; then
    # No DDC monitor found, send empty JSON to hide module
    echo '{"text": "", "class": "hidden"}'
    exit 0
fi

case $1 in
    "up")
        ddcutil setvcp 10 + 10
        ;;
    "down")
        ddcutil setvcp 10 - 10
        ;;
    *)
        # Get current brightness and format for Waybar
        BRIGHTNESS=$(ddcutil getvcp 10 | grep -oP 'current value =\s+\K[0-9]+')
        echo "{\"text\": \" $BRIGHTNESS%\", \"tooltip\": \"External Monitor Brightness\"}"
        ;;
esac
