#!/usr/bin/env bash
# osd-bar — ASCII progress-bar OSD for volume + brightness, rendered via mako.
#
# Usage:
#   osd-bar                  daemon mode: watch for volume/brightness changes
#                            and pop a self-replacing mako "OSD" bar.
#   osd-bar volume [pct [1]] one-shot render (arg2 = percent, arg3 non-empty = muted)
#   osd-bar brightness [pct] one-shot render
#   osd-bar --help
#
# Start once from your WM autostart:
#   sway / i3:      exec    ~/.local/bin/osd-bar
#   Hyprland:       exec-once = ~/.local/bin/osd-bar
#
# Self-replacement: every update reuses the same mako synchronous hint
# (string:x-canonical-private-synchronous:volume|brightness), so mako swaps
# the previous bar in place instead of stacking a pile of notifications
# (works on mako >= 1.6).
#
# Env overrides: BAR_WIDTH FILL EMPTY VOL_TITLE BRI_TITLE OSD_TIMEOUT_MS
#                POLL_INTERVAL OSD_DRYRUN
set -u

# --- look ----------------------------------------------------------------
BAR_WIDTH=30             # number of bar cells
FILL='█'                 # filled cell   (try '▓', '●', '=')
EMPTY='░'                # empty cell    (try '·', '-')
VOL_TITLE='Volume'       # e.g. '🔊 Volume' if your fonts render emoji
BRI_TITLE='Brightness'
OSD_TIMEOUT_MS=2000      # overlay auto-dismiss in ms ('' = mako default)
POLL_INTERVAL=0.2        # brightness poll seconds (sysfs can't be inotify-watched)
OSD_DRYRUN=${OSD_DRYRUN:-0}   # 1 = print instead of notifying (testing)

die() { printf 'osd-bar: %s\n' "$*" >&2; exit 1; }
command -v notify-send >/dev/null 2>&1 || die 'notify-send (libnotify) not found'

# --- rendering -------------------------------------------------------------
bar() {                       # $1: percent -> "[███████░░░░░░]  58%"
    local p=$1 w=$BAR_WIDTH out= i=0 n
    (( p < 0   )) && p=0
    (( p > 100 )) && p=100
    n=$(( p * w / 100 ))
    while (( i < w )); do
        (( i++ < n )) && out+=$FILL || out+=$EMPTY
    done
    printf '[%s] %3d%%' "$out" "$p"
}

show() {                      # $1 kind  $2 percent  $3 muted 0|1 (volume)
    local kind=$1 pct=$2 muted=${3:-0} title body targs=()
    if [ "$kind" = volume ]; then
        title=$VOL_TITLE
        (( muted )) && title="$VOL_TITLE (muted)"
    else
        title=$BRI_TITLE
    fi
    body=$(bar "$pct")
    if [ "$OSD_DRYRUN" = 1 ]; then
        printf 'NOTIFY title=%q body=%q\n' "$title" "$body"
        return 0
    fi
    [ -n "${OSD_TIMEOUT_MS}" ] && targs=(-t "$OSD_TIMEOUT_MS")
    notify-send -u low -a osd-bar "${targs[@]}" \
        -h "string:x-canonical-private-synchronous:$kind" \
        "$title" "$body"
}

# --- sources ----------------------------------------------------------------
get_volume() {                # prints "PERCENT MUTED"; fails if no source
    if command -v wpctl >/dev/null 2>&1; then
        local out
        out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || return 1
        awk '/^Volume:/ {
                 m = ($0 ~ /MUTED/) ? 1 : 0
                 printf "%d %d\n", $2 * 100 + 0.5, m
                 found = 1; exit
             }
             END { exit found ? 0 : 1 }' <<<"$out" && return 0
    fi
    command -v pactl >/dev/null 2>&1 || return 1
    local pct m=0
    pct=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null \
          | grep -om1 '[0-9]\{1,\}%' | tr -d '%') || return 1
    [ -n "$pct" ] || return 1
    pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -qw yes && m=1
    printf '%d %d\n' "$pct" "$m"
}

get_brightness() {            # prints "PERCENT"; fails if no backlight
    local d cur max
    for d in /sys/class/backlight/*/; do
        [ -r "${d}brightness" ] || continue
        cur=$(<"${d}brightness")
        max=$(<"${d}max_brightness")
        [ -n "$cur" ] && [ -n "$max" ] && [ "$max" -gt 0 ] || continue
        printf '%d\n' $(( cur * 100 / max ))
        return 0
    done
    if command -v brightnessctl >/dev/null 2>&1; then
        cur=$(brightnessctl g 2>/dev/null) || return 1
        max=$(brightnessctl m 2>/dev/null) || return 1
        [ -n "$cur" ] && [ -n "$max" ] && [ "$max" -gt 0 ] || return 1
        printf '%d\n' $(( cur * 100 / max ))
        return 0
    fi
    return 1
}

# --- watchers ----------------------------------------------------------------
watch_volume() {              # pactl pushes events; dedupe by comparing state
    local prev= v= ev
    v=$(get_volume 2>/dev/null) || v=x
    prev=$v
    while read -r ev; do
        case "$ev" in *" on sink "*|*" on server "*) ;; *) continue ;; esac
        v=$(get_volume) || continue
        [ "$v" = "$prev" ] && continue
        prev=$v
        show volume "${v%% *}" "${v##* }"
    done < <(stdbuf -oL pactl subscribe 2>/dev/null)
    printf 'osd-bar: volume watcher exited (audio server gone?)\n' >&2
}

watch_brightness() {          # sysfs emits no inotify events -> short poll
    local prev= v=
    v=$(get_brightness 2>/dev/null) || v=x
    prev=$v
    while sleep "$POLL_INTERVAL"; do
        v=$(get_brightness) || continue
        [ "$v" = "$prev" ] && continue
        prev=$v
        show brightness "$v"
    done
}

usage() {
    cat <<'EOF'
osd-bar — ASCII progress-bar OSD (volume + brightness) via mako

  osd-bar                    daemon: watch volume + brightness, show mako bar
  osd-bar volume [% [1]]     render volume bar now (arg2 non-empty = muted)
  osd-bar brightness [%]     render brightness bar now

Env: BAR_WIDTH FILL EMPTY VOL_TITLE BRI_TITLE OSD_TIMEOUT_MS
     POLL_INTERVAL OSD_DRYRUN
EOF
}

# --- main ---------------------------------------------------------------------
case ${1:-''} in
    volume)
        [ $# -ge 2 ] && { show volume "${2:-0}" "${3:-0}"; exit 0; }
        v=$(get_volume) || die 'no volume source (want wpctl or pactl + running audio server)'
        show volume "${v%% *}" "${v##* }"
        ;;
    brightness)
        [ $# -ge 2 ] && { show brightness "$2"; exit 0; }
        v=$(get_brightness) || die 'no backlight found (sysfs or brightnessctl)'
        show brightness "$v"
        ;;
    -h|--help|help)
        usage
        ;;
    '')  # daemon
        watch_volume &   VPID=$!
        watch_brightness & BPID=$!
        stop() { kill "$VPID" "$BPID" 2>/dev/null; }
        trap stop INT TERM
        printf 'osd-bar: watching (volume pid %s, brightness pid %s)\n' "$VPID" "$BPID" >&2
        wait
        ;;
    *)
        die "unknown argument '$1' (see --help)"
        ;;
esac
exit 0
