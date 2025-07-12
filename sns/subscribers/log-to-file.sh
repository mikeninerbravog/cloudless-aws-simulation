#!/bin/bash
mkdir -p logs
echo "[SNS] $(date "+%F %T") - $(cat)" >> logs/sns.log
