#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-}"
LINES="${LINES:-120}"

if [ -z "$LOG_FILE" ]; then
  echo "Refusing to run: set LOG_FILE explicitly, for example LOG_FILE=/var/log/app/app.log."
  exit 0
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "LOG_FILE is not a file or cannot be found: $LOG_FILE"
  exit 0
fi

echo "== tail $LINES lines from $LOG_FILE =="
tail -n "$LINES" "$LOG_FILE" 2>/dev/null || echo "Cannot read $LOG_FILE; check permissions."
