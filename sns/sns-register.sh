#!/bin/bash
set -e

TOPIC="$1"
SCRIPT="$2"
mkdir -p sns/topics
echo "$SCRIPT" >> "sns/topics/$TOPIC.subs"
echo "[SNS] Registered $SCRIPT under topic '$TOPIC'"
