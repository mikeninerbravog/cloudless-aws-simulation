#!/bin/bash
# lambda.sh - Simulated AWS Lambda triggered by file event
# Author: Mike Niner Bravog

DB="db.sqlite"
LOG_DIR="logs"

FILE="$1"

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "[ERROR] Invalid or missing file: $FILE"
    exit 1
fi

BASENAME=$(basename "$FILE")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
HASH=$(sha256sum "$FILE" | awk '{print $1}')
LOGFILE="$LOG_DIR/${BASENAME}.log"

# Log to file
{
    echo "[LAMBDA] File: $BASENAME"
    echo "[LAMBDA] Time: $TIMESTAMP"
    echo "[LAMBDA] SHA256: $HASH"
} > "$LOGFILE"

# Insert into SQLite
sqlite3 "$DB" <<EOF
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT,
    sha256 TEXT,
    timestamp TEXT
);
INSERT INTO events (filename, sha256, timestamp)
VALUES ('$BASENAME', '$HASH', '$TIMESTAMP');
EOF

echo "[OK] Lambda processed $BASENAME (hash: $HASH)"

# Optional SNS publish (topic: s3new)
if [[ -x sns/sns-publish.sh ]]; then
    bash sns/sns-publish.sh s3new "New file processed: $BASENAME"
fi

# Optional S3 Sync (archive move)
if [[ -x s3sync.sh ]]; then
    bash s3sync.sh
fi
