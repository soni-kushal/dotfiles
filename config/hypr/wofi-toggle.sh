#!/bin/bash

if pgrep -x wofi > /dev/null; then
    pkill -x wofi
else
    wofi --show drun --style ~/.config/wofi/style.css
fi

