#!/bin/bash
# sqs-send.sh - Simulated SQS message sender (enqueue)
# Author: Mike Niner Bravog

DB="db.sqlite"
MSG="$1"

# Read from stdin if not passed as argument
if [[ -z "$MSG" ]]; then
    read -r MSG
fi

if [[ -z "$MSG" ]]; then
    echo "[ERROR] Empty message. Usage: sqs-send.sh 'your message here'" >&2
    exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Insert message into queue and fetch ID
ID=$(sqlite3 "$DB" <<EOF
BEGIN;
CREATE TABLE IF NOT EXISTS queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    body TEXT NOT NULL,
    timestamp TEXT,
    consumed INTEGER DEFAULT 0
);
INSERT INTO queue (body, timestamp, consumed)
VALUES ('$MSG', '$TIMESTAMP', 0);
SELECT last_insert_rowid();
COMMIT;
EOF
)

echo "[ENQUEUED] ID: $ID | Time: $TIMESTAMP"
