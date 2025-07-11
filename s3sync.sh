#!/bin/bash
# s3sync.sh - Simulates 'aws s3 sync' by moving processed files
# Author: Mike Niner Bravog

SRC_DIR="input"
DST_DIR="archive"
LOG_DIR="logs"

mkdir -p "$DST_DIR"

for FILE in "$SRC_DIR"/*; do
    [ -f "$FILE" ] || continue
    BASENAME=$(basename "$FILE")
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    HASH=$(sha256sum "$FILE" | awk '{print $1}')
    DEST="$DST_DIR/${HASH}_${BASENAME}"

    if [[ -e "$DEST" ]]; then
        echo "[SKIP] $BASENAME already synced."
        continue
    fi

    mv "$FILE" "$DEST"

    echo "[SYNC] $BASENAME -> $DEST" >> "$LOG_DIR/s3sync.log"
    echo "[OK] $BASENAME moved to archive as $DEST"
done
