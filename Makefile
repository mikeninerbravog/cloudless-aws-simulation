# Makefile - Project: cloudless-aws-simulation
# Author: Mike Niner Bravog
# DevOps-style orchestration for AWS simulation without AWS

.PHONY: all setup clean reset run

## Default target: show help
all:
	@echo "Available targets:"
	@echo "  setup   - Create project directories and empty database"
	@echo "  reset   - Clean logs and reset the SQLite database"
	@echo "  run     - Start file watcher (inotify)"
	@echo "  clean   - Remove all generated files (use with caution)"

## Setup directories and SQLite DB
setup:
	@mkdir -p input logs
	@test -f db.sqlite || sqlite3 db.sqlite "CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY, filename TEXT, sha256 TEXT, timestamp TEXT);"
	@echo "[OK] Project structure created."

## Remove logs and database entries
reset:
	@rm -f logs/*.log
	@sqlite3 db.sqlite "DELETE FROM events;"
	@echo "[OK] Logs cleared and database reset."

## Run the watcher (foreground)
run:
	@echo "[INFO] Watching input/ for new files..."
	@bash watcher.sh

## Danger zone
clean:
	@rm -rf input/* logs/* db.sqlite
	@echo "[WARNING] Project files removed."

## Sync processed files to archive/ (S3 Simulation)
sync:
	@echo "[MAKE] Starting sync: input/ -> archive/"
	@bash s3sync.sh
	@echo "[DONE] All eligible files have been archived."

