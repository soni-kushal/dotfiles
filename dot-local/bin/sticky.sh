#!/usr/bin/env bash

SESSION="sticky"

# Change this to your project directory
PROJECT_DIR="$HOME/notes/sticky"

# The three files to open
FILE1="$PROJECT_DIR/open.md"
FILE2="$PROJECT_DIR/reminders.md"
FILE3="$PROJECT_DIR/ideas.md"

# If the session already exists, reconnect to it
if tmux has-session -t "$SESSION" 2>/dev/null; then
    if [ -n "${TMUX:-}" ]; then
        tmux switch-client -t "$SESSION"
    else
        tmux attach-session -t "$SESSION"
    fi
    exit 0
fi

# Create a new detached session
tmux new-session -d -s "$SESSION" -c "$PROJECT_DIR"

# Create the remaining three panes
tmux split-window -h -t "$SESSION:1.1"
tmux split-window -v -t "$SESSION:1.1"
tmux split-window -v -t "$SESSION:1.2"

# Apply a 2x2 layout
tmux select-layout -t "$SESSION:1" tiled

# Launch Neovim in the first three panes
tmux send-keys -t "$SESSION:1.1" "nvim -- $(printf '%q' "$FILE1")" C-m
tmux send-keys -t "$SESSION:1.2" "nvim -- $(printf '%q' "$FILE2")" C-m
tmux send-keys -t "$SESSION:1.3" "nvim -- $(printf '%q' "$FILE3")" C-m

# Launch Taskwarrior in the fourth pane
tmux send-keys -t "$SESSION:1.4" "task" C-m

# Select the first pane
tmux select-pane -t "$SESSION:1.1"

# Attach to the session
if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$SESSION"
else
    tmux attach-session -t "$SESSION"
fi
