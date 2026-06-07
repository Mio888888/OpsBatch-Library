#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-}"
CONFIRM_TRUNCATE="${CONFIRM_TRUNCATE:-}"

if [ -z "$LOG_FILE" ]; then
  echo "Refusing to run: set LOG_FILE explicitly, for example LOG_FILE=/var/log/myapp/app.log."
  exit 0
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "LOG_FILE is not a file or cannot be found: $LOG_FILE"
  exit 0
fi

echo "== target log file =="
ls -lh "$LOG_FILE" 2>/dev/null || true
echo
echo "== last 20 lines before truncate =="
tail -n 20 "$LOG_FILE" 2>/dev/null || true

if [ "$CONFIRM_TRUNCATE" != "TRUNCATE_LOG_FILE" ]; then
  echo
  echo "Dry-run only. Set CONFIRM_TRUNCATE=TRUNCATE_LOG_FILE to truncate this single file after confirming the writer process and backup requirements."
  exit 0
fi

echo
echo "Truncating $LOG_FILE. This preserves the file inode but removes existing content."
: > "$LOG_FILE"
ls -lh "$LOG_FILE" 2>/dev/null || true
