#!/bin/bash

input="$1"
output="$2"
target_kb="$3"
target_bytes=$((target_kb * 1024))

for dpi in 150 120 100 80 60 50 40 30 20; do
    gs -q -dNOPAUSE -dBATCH \
       -sDEVICE=pdfwrite \
       -dCompatibilityLevel=1.4 \
       -dDownsampleColorImages=true \
       -dColorImageResolution=$dpi \
       -dDownsampleGrayImages=true \
       -dGrayImageResolution=$dpi \
       -dDownsampleMonoImages=true \
       -dMonoImageResolution=$dpi \
       -sOutputFile="$output" \
       "$input"

    size=$(stat -c%s "$output")

    echo "DPI=$dpi → $size bytes"

    if [ "$size" -le "$target_bytes" ]; then
        echo "Done: $output ($(du -h "$output" | cut -f1))"
        exit 0
    fi
done

echo "Could not get the PDF below ${target_kb} KB."
exit 1

