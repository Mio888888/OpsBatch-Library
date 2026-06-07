#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-}"
LOG_PATTERN="${LOG_PATTERN:-error|fail|exception|timeout|critical}"
LINES="${LINES:-120}"

if [ -z "$LOG_FILE" ]; then
  echo "Refusing to run: set LOG_FILE explicitly, for example LOG_FILE=/var/log/app/app.log."
  exit 0
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "LOG_FILE is not a file or cannot be found: $LOG_FILE"
  exit 0
fi

echo "== search pattern in $LOG_FILE =="
echo "Pattern: $LOG_PATTERN"
grep -Ein "$LOG_PATTERN" "$LOG_FILE" 2>/dev/null | tail -n "$LINES" || echo "No matches found or file cannot be read."
