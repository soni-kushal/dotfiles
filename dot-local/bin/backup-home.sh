#!/bin/bash

# --- Configuration Section ---
SOURCE_DIR="/home/billu/"  # Path to the directory you want to back up (change as needed)

# Exclusion list (modify this with the folders you want to exclude from the backup)
EXCLUDES=(
    "/.cache"
    "/.thumbnails"
    "/.local"
	"/.config"
	"/.pki"
    "/.zen"
    "/.zotero"
    "/.mozilla"
)

# --- End of Configuration ---

# Ask for the destination disk path
echo "Please enter the path to the external disk (e.g., /mnt/external/backup):"
read -r BACKUP_DIR

# Check if the destination directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: The destination directory $BACKUP_DIR does not exist. Exiting..."
    exit 1
fi

# Build the rsync exclude options from the EXCLUDES array
EXCLUDE_ARGS=()
for item in "${EXCLUDES[@]}"; do
    EXCLUDE_ARGS+=("--exclude=$item")
done

# Perform the backup using rsync with the specified exclusions
echo "Starting backup of $SOURCE_DIR to $BACKUP_DIR..."
rsync -avhPn --info=progress2 --delete "${EXCLUDE_ARGS[@]}" "$SOURCE_DIR" "$BACKUP_DIR"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully!"
else
    echo "Backup failed."
fi
