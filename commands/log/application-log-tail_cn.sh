#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-}"
LINES="${LINES:-120}"

if [ -z "$LOG_FILE" ]; then
  echo "拒绝执行： set LOG_FILE explicitly, for example LOG_FILE=/var/log/app/app.log.（Refusing to run: set LOG_FILE explicitly, for example LOG_FILE=/var/log/app/app.log.）"
  exit 0
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "信息：LOG_FILE is not a file or cannot be found: $LOG_FILE"
  exit 0
fi

echo "信息：== tail $LINES lines from $LOG_FILE =="
tail -n "$LINES" "$LOG_FILE" 2>/dev/null || echo "无法读取 $LOG_FILE; check permissions.（Cannot read $LOG_FILE; check permissions.）"
