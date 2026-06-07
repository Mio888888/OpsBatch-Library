#!/usr/bin/env bash
set -euo pipefail

TARGET_LOG_DIR="${TARGET_LOG_DIR:-}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-30}"
CONFIRM_DELETE="${CONFIRM_DELETE:-}"

if [ -z "$TARGET_LOG_DIR" ]; then
  echo "Refusing to run: set TARGET_LOG_DIR explicitly, for example TARGET_LOG_DIR=/var/log/myapp."
  exit 0
fi

if [ ! -d "$TARGET_LOG_DIR" ]; then
  echo "TARGET_LOG_DIR is not a directory: $TARGET_LOG_DIR"
  exit 0
fi

echo "== old log cleanup candidates under $TARGET_LOG_DIR older than $OLDER_THAN_DAYS days =="
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.*' -o -name '*.gz' -o -name '*.zip' -o -name '*.xz' -o -name '*.bz2' -o -name '*.old' \) \
  -mtime +"$OLDER_THAN_DAYS" -print 2>/dev/null | head -100

if [ "$CONFIRM_DELETE" != "DELETE_OLD_LOGS" ]; then
  echo
  echo "Dry-run only. Set CONFIRM_DELETE=DELETE_OLD_LOGS to interactively delete matched old log files after reviewing retention and audit requirements."
  exit 0
fi

echo
echo "Deleting matched old logs interactively. Answer each prompt carefully."
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.*' -o -name '*.gz' -o -name '*.zip' -o -name '*.xz' -o -name '*.bz2' -o -name '*.old' \) \
  -mtime +"$OLDER_THAN_DAYS" -exec rm -i {} \;
