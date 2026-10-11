#!/bin/bash

# Get the current TLP mode
STATUS=$(tlp-stat -s | grep "^TLP profile" | awk '{print $4}')

if [ "$STATUS" = "power-saver/SAV" ]; then
    echo "" # Icon for Battery/Power Save
elif [ "$STATUS" = "performance/AC" ]; then
    echo "" # Icon for AC/Performance
else
    echo "" # Fallback icon
fi
