#!/usr/bin/env bash
set -euo pipefail

TARGET_LOG_DIR="${TARGET_LOG_DIR:-}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-7}"
CONFIRM_COMPRESS="${CONFIRM_COMPRESS:-}"

if [ -z "$TARGET_LOG_DIR" ]; then
  echo "拒绝执行： set TARGET_LOG_DIR explicitly, for example TARGET_LOG_DIR=/var/log/myapp.（Refusing to run: set TARGET_LOG_DIR explicitly, for example TARGET_LOG_DIR=/var/log/myapp.）"
  exit 0
fi

if [ ! -d "$TARGET_LOG_DIR" ]; then
  echo "信息：TARGET_LOG_DIR is not a directory: $TARGET_LOG_DIR"
  exit 0
fi

echo "信息：== old uncompressed rotated log candidates under $TARGET_LOG_DIR older than $OLDER_THAN_DAYS days =="
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.[0-9]*' -o -name '*.out.[0-9]*' -o -name '*.err.[0-9]*' -o -name '*.old' \) \
  ! -name '*.gz' ! -name '*.zip' ! -name '*.xz' ! -name '*.bz2' \
  -mtime +"$OLDER_THAN_DAYS" -print 2>/dev/null | head -100

if [ "$CONFIRM_COMPRESS" != "COMPRESS_OLD_LOGS" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_COMPRESS=COMPRESS_OLD_LOGS to gzip matched rotated files after reviewing backups, retention policy, and active writers.（Dry-run only. Set CONFIRM_COMPRESS=COMPRESS_OLD_LOGS to gzip matched rotated files after reviewing backups, retention policy, and active writers.）"
  exit 0
fi

echo
echo "信息：Compressing matched old rotated logs. Review active writers and retention policy before use."
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.[0-9]*' -o -name '*.out.[0-9]*' -o -name '*.err.[0-9]*' -o -name '*.old' \) \
  ! -name '*.gz' ! -name '*.zip' ! -name '*.xz' ! -name '*.bz2' \
  -mtime +"$OLDER_THAN_DAYS" -exec gzip -v {} \;
