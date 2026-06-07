#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-7}"
CONFIRM_DELETE="${CONFIRM_DELETE:-}"

if [ -z "$TARGET_DIR" ]; then
  echo "Refusing to run: set TARGET_DIR explicitly, for example TARGET_DIR=/tmp."
  exit 0
fi

if [ "$CONFIRM_DELETE" != "DELETE_TEMP_CANDIDATES" ]; then
  echo "Dry-run only. Set CONFIRM_DELETE=DELETE_TEMP_CANDIDATES to delete matched files."
  find "$TARGET_DIR" -xdev -mindepth 1 -maxdepth 2 -mtime +"$OLDER_THAN_DAYS" -print 2>/dev/null | head -100
  exit 0
fi

echo "Deleting candidates under $TARGET_DIR older than $OLDER_THAN_DAYS days. Review command and backups before use."
find "$TARGET_DIR" -xdev -mindepth 1 -maxdepth 2 -mtime +"$OLDER_THAN_DAYS" -exec rm -ri {} +
