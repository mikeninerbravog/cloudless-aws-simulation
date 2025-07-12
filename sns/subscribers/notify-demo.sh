#!/bin/bash
MSG=$(cat)
mkdir -p logs
{
echo "[SNS-DEMO] $(date "+%F %T")"
echo "[SNS-DEMO] Simulated fan-out notification:"
echo "[SNS-DEMO] Message: $MSG"
echo "[SNS-DEMO] This message *could* have been delivered via:"
echo "            - SMS (e.g., Twilio, AWS SNS SMS)"
echo "            - Email (SMTP relay or SendGrid)"
echo "            - Webhook (external system)"
echo "[SNS-DEMO] [POC mode: local log only]"
echo "---"
} >> logs/sns-demo.log
