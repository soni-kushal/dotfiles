#!/bin/bash

alacritty -o "font.size=14" --class "sdcv-popup" --title "Dictionary Lookup" -e bash -c "
    # Prompt the user for input
    printf 'Enter word to look up: '
    read -r word

    # Check if a word was entered
    if [ -n \"\$word\" ]; then
        echo '--- Results for: '\$word' ---'
        # sdcv output piped to less
        # We use -E to make less exit automatically when it reaches end-of-file
        # sdcv --color \"\$word\" | tail -n +6 | less -RFX
        sdcv --color \"\$word\" | less -RFX
    else
        echo 'No word entered.'
    fi

    echo
    echo '--- Press any key to close ---'
    read -n 1 -s
"
