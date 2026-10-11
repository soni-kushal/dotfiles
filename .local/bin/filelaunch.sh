#!/bin/bash
# Search /home, excluding hidden files for speed, and open with default app
#
cd "$HOME" || exit

SELECTION=$(fd . $HOME --type f --hidden --exclude .cache | fuzzel -d -p "Search Files: " --width 80)

if [ -n "$SELECTION" ]; then
    xdg-open "$SELECTION"
fi
