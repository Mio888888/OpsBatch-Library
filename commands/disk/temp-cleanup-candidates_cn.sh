#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-/tmp}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-7}"

echo "信息：== cleanup candidates in $TARGET_DIR older than $OLDER_THAN_DAYS days =="
if [ -d "$TARGET_DIR" ]; then
  find "$TARGET_DIR" -xdev -mindepth 1 -mtime +"$OLDER_THAN_DAYS" -maxdepth 2 -print 2>/dev/null | head -100
  echo
  echo "信息：This command only lists candidates and does not delete anything. Review owners and active processes before cleanup."
else
  echo "信息：TARGET_DIR is not a directory: $TARGET_DIR"
fi
