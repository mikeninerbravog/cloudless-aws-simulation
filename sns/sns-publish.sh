#!/bin/bash
set -e

TOPIC="$1"
MESSAGE="$2"

SUB_FILE="sns/topics/$TOPIC.subs"
if [ ! -f "$SUB_FILE" ]; then
  echo "[SNS] No subscribers for topic '$TOPIC'"
  exit 1
fi

while read -r SCRIPT; do
  echo "$MESSAGE" | bash "$SCRIPT"
done < "$SUB_FILE"
