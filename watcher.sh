#!/bin/bash
# watcher.sh - Watches input/ folder and triggers lambda.sh on new file
# Author: Mike Niner Bravog

INPUT_DIR="input"
LOG_DIR="logs"
LAMBDA_SCRIPT="./lambda.sh"

# Ensure inotifywait is installed
command -v inotifywait >/dev/null 2>&1 || {
    echo "[ERROR] inotify-tools not installed. Please run: apt install inotify-tools" >&2
    exit 1
}

# Ensure lambda script exists
if [[ ! -x "$LAMBDA_SCRIPT" ]]; then
    echo "[ERROR] Lambda script not found or not executable: $LAMBDA_SCRIPT"
    exit 1
fi

echo "[INFO] Starting watcher on '$INPUT_DIR'..."
echo "[INFO] Press Ctrl+C to stop."

# Monitor new files only (close_write ensures file is fully written)
inotifywait -m -e close_write --format '%w%f' "$INPUT_DIR" | while read FILEPATH; do
    BASENAME=$(basename "$FILEPATH")
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[EVENT] New file detected: $BASENAME at $TIMESTAMP"

    # Trigger the simulated Lambda
    "$LAMBDA_SCRIPT" "$FILEPATH"
done
