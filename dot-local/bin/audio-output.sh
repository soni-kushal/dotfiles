#!/usr/bin/env bash

set -euo pipefail

# Get active audio output sinks
sinks=$(wpctl status -n | awk '
    /Sinks:/ { in_sinks=1; next }
    /Sources:/ { in_sinks=0 }
    in_sinks && /^[[:space:]]*[│├└]/ {
        line=$0
        if (line ~ /\[vol:/) {
            sub(/^[[:space:]│├└*]+/, "", line)
            print line
        }
    }
')

# Let fuzzel select an output
selected=$(printf '%s\n' "$sinks" | fuzzel --dmenu \
    --prompt="Audio output: " \
    --placeholder="Select output..." \
	--lines=4\
	--width=80\
    ) || exit 0

[[ -z "$selected" ]] && exit 0

# Extract PipeWire sink ID
sink_id=$(awk '{print $1}' <<< "$selected")

# Set selected sink as default
wpctl set-default "$sink_id"

# Optional: move existing audio streams to the new sink
wpctl status -n | awk '
    /Streams:/ { in_streams=1; next }
    in_streams && /^[[:space:]]*[│├└]/ {
        line=$0
        if (line ~ /output_/ && line ~ /[0-9]+/) {
            sub(/^[[:space:]│├└*]+/, "", line)
            print line
        }
    }
' | while read -r stream; do
    stream_id=$(awk '{print $1}' <<< "$stream")
    wpctl move "$stream_id" "$sink_id" 2>/dev/null || true
done
