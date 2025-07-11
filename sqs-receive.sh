#!/bin/bash
# sqs-receive.sh - Simulated SQS message receiver (dequeue)
# Author: Mike Niner Bravog

DB="db.sqlite"

# Fetch the first unconsumed message
RESULT=$(sqlite3 "$DB" <<EOF
SELECT id, body, timestamp FROM queue
WHERE consumed = 0
ORDER BY id ASC
LIMIT 1;
EOF
)

if [[ -z "$RESULT" ]]; then
    echo "[INFO] No messages in the queue."
    exit 0
fi

# Parse fields
IFS='|' read -r ID BODY TIMESTAMP <<< "$RESULT"

# Mark message as consumed
sqlite3 "$DB" "UPDATE queue SET consumed = 1 WHERE id = $ID;"

# Output message
echo "[RECEIVED] ID: $ID"
echo "[TIME]     $TIMESTAMP"
echo "[BODY]     $BODY"
