````markdown
#  Manual Test Instructions — cloudless-aws-simulation

This document outlines the step-by-step manual test procedures for validating each module in the POC.  
All tests are executed on a clean Linux VPS (Debian-based). No external dependencies.

---

##  1. Setup Structure

```bash
sudo apt update
sudo apt install -y inotify-tools sqlite3
make setup
````

Expected:

* `input/` and `logs/` directories created
* `db.sqlite` initialized with `events` table

---

##  2. Test `lambda.sh` (Standalone)

```bash
echo "test lambda content" > input/test-lambda.txt
chmod +x lambda.sh
./lambda.sh input/test-lambda.txt
```

Expected:

* Log file: `logs/test-lambda.txt.log`
* DB entry in `db.sqlite`

Verify:

```bash
cat logs/test-lambda.txt.log
sqlite3 db.sqlite "SELECT * FROM events;"
```

---

##  3. Test `watcher.sh` + Lambda

```bash
chmod +x watcher.sh
make run
```

From another terminal:

```bash
echo "trigger from watcher" > input/test-watcher.txt
```

Expected:

* Output in terminal: `[EVENT] New file detected: test-watcher.txt ...`
* Lambda log created in `logs/`
* DB updated with the new event

Verify:

```bash
sqlite3 db.sqlite "SELECT * FROM events WHERE filename='test-watcher.txt';"
```

---

## 🧼 4. Reset Test Environment

```bash
make reset
```

Expected:

* Log files removed
* SQLite database cleared (but not deleted)

---

## ☠️ 5. Clean All

```bash
make clean
```

Expected:

* All files under `input/`, `logs/`, and `db.sqlite` are removed

---

## Notes

* All logs are timestamped.
* All failures are printed to stderr.
* You can extend the test suite by piping new file types or running `make run` inside a `tmux` session.

```
