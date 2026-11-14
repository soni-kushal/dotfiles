#!/usr/bin/env bash

PIDFILE="$HOME/.cache/lid-inhibit.pid"

mkdir -p "$HOME/.cache"

if [[ -f "$PIDFILE" ]]; then
    PID=$(cat "$PIDFILE")

    if kill -0 "$PID" 2>/dev/null; then
        # Turn normal lid behavior back on
        kill "$PID"
        rm -f "$PIDFILE"
    else
        rm -f "$PIDFILE"
    fi
else
    # Disable lid-triggered suspend
    systemd-inhibit \
        --what=handle-lid-switch \
        --mode=block \
        --why="Lid sleep toggle" \
        sleep infinity \
        >/dev/null 2>&1 </dev/null &

    echo $! > "$PIDFILE"
fi

# Give the inhibitor a moment to start
sleep 0.2

# Output Waybar JSON
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo '{"text":"󰌾 Lid: Awake","class":"awake","tooltip":"Lid close will not suspend. Click to restore normal behavior."}'
else
    rm -f "$PIDFILE"
    echo '{"text":"󰌾 Lid: Sleep","class":"sleep","tooltip":"Lid close will suspend normally. Click to disable lid sleep."}'
fi
