# Makefile - Project: cloudless-aws-simulation
# Author: Mike Niner Bravog
# DevOps-style orchestration for AWS simulation without AWS

.PHONY: all setup reset clean run sync sns-test sns-reset sns-integrate

## Default target: show help
all:
	@echo "Available targets:"
	@echo "  setup         - Create project directories and empty database"
	@echo "  reset         - Clean logs and reset the SQLite database"
	@echo "  run           - Start full pipeline (watcher + sync + sns)"
	@echo "  sync          - Archive processed files (S3 Simulation)"
	@echo "  sns-test      - Run standalone SNS test"
	@echo "  sns-integrate - Setup SNS subscriber for s3new topic"
	@echo "  sns-reset     - Clear SNS topic subscriptions"
	@echo "  clean         - Remove ALL files (use with caution)"

## Setup directories and SQLite DB
setup:
	@mkdir -p input logs archive sns/topics
	@test -f db.sqlite || sqlite3 db.sqlite "CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY, filename TEXT, sha256 TEXT, timestamp TEXT);"
	@echo "[OK] Project structure created."

## Reset logs and clean DB (but keep archive and topics)
reset:
	@rm -f logs/*.log logs/sns.log
	@sqlite3 db.sqlite "DELETE FROM events;"
	@echo "[OK] Logs cleared and database reset."

## Clean everything (danger zone)
clean:
	@rm -rf input/* logs/* archive/* db.sqlite sns/topics/*.subs
	@echo "[WARNING] Project files wiped."

## Run watcher (triggers lambda, then sync, then sns automatically)
run:
	@echo "[INIT] Resetting SNS and logs..."
	@$(MAKE) sns-reset
	@$(MAKE) sns-integrate
	@echo "[INFO] Watching input/ for new files..."
	@bash watcher.sh

## Archive processed files (S3 sync behavior)
sync:
	@echo "[SYNC] Archiving new files from input/ to archive/"
	@bash s3sync.sh
	@echo "[SYNC] Done."

## SNS test: manual publishing to a test topic
sns-test:
	@echo "[TEST] Registering test subscriber to 'alert' topic"
	bash sns/sns-register.sh alert sns/test/test-subscriber.sh
	@echo "[TEST] Publishing message to topic 'alert'"
	bash sns/sns-publish.sh alert "🔥 Test Message"
	@echo "[TEST] SNS test complete."

## Setup real subscriber for SNS integration with lambda
sns-integrate:
	@mkdir -p sns/subscribers

	# Subscriber 1 - log-to-file.sh
	@echo '#!/bin/bash' > sns/subscribers/log-to-file.sh
	@echo 'mkdir -p logs' >> sns/subscribers/log-to-file.sh
	@echo 'echo "[SNS] $$(date "+%F %T") - $$(cat)" >> logs/sns.log' >> sns/subscribers/log-to-file.sh
	@chmod +x sns/subscribers/log-to-file.sh
	@bash sns/sns-register.sh s3new sns/subscribers/log-to-file.sh

	# Subscriber 2 - notify-demo.sh
	@echo '#!/bin/bash' > sns/subscribers/notify-demo.sh
	@echo 'MSG=$$(cat)' >> sns/subscribers/notify-demo.sh
	@echo 'mkdir -p logs' >> sns/subscribers/notify-demo.sh
	@echo '{' >> sns/subscribers/notify-demo.sh
	@echo 'echo "[SNS-DEMO] $$(date "+%F %T")"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "[SNS-DEMO] Simulated fan-out notification:"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "[SNS-DEMO] Message: $$MSG"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "[SNS-DEMO] This message *could* have been delivered via:"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "            - SMS (e.g., Twilio, AWS SNS SMS)"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "            - Email (SMTP relay or SendGrid)"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "            - Webhook (external system)"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "[SNS-DEMO] [POC mode: local log only]"' >> sns/subscribers/notify-demo.sh
	@echo 'echo "---"' >> sns/subscribers/notify-demo.sh
	@echo '} >> logs/sns-demo.log' >> sns/subscribers/notify-demo.sh
	@chmod +x sns/subscribers/notify-demo.sh
	@bash sns/sns-register.sh s3new sns/subscribers/notify-demo.sh

	@echo "[SNS] Subscribers registered on topic 's3new'"


## Remove all SNS topic subscribers
sns-reset:
	@rm -f sns/topics/*.subs
	@rm -f logs/sns.log
	@echo "[SNS] Subscriptions and log cleared."
