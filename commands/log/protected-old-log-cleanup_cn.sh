#!/usr/bin/env bash
set -euo pipefail

TARGET_LOG_DIR="${TARGET_LOG_DIR:-}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-30}"
CONFIRM_DELETE="${CONFIRM_DELETE:-}"

if [ -z "$TARGET_LOG_DIR" ]; then
  echo "拒绝执行： 请显式设置 TARGET_LOG_DIR，例如 TARGET_LOG_DIR=/var/log/myapp。"
  exit 0
fi

if [ ! -d "$TARGET_LOG_DIR" ]; then
  echo "信息：TARGET_LOG_DIR 不是目录: $TARGET_LOG_DIR"
  exit 0
fi

echo "信息：== $TARGET_LOG_DIR 中早于 $OLDER_THAN_DAYS 天的旧日志清理候选项 =="
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.*' -o -name '*.gz' -o -name '*.zip' -o -name '*.xz' -o -name '*.bz2' -o -name '*.old' \) \
  -mtime +"$OLDER_THAN_DAYS" -print 2>/dev/null | head -100

if [ "$CONFIRM_DELETE" != "DELETE_OLD_LOGS" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_DELETE=DELETE_OLD_LOGS ，在复核保留和审计要求后交互式删除匹配的旧日志文件。"
  exit 0
fi

echo
echo "信息：正在交互式删除匹配的旧日志。请谨慎回答每个提示。"
find "$TARGET_LOG_DIR" -xdev -type f \
  \( -name '*.log.*' -o -name '*.gz' -o -name '*.zip' -o -name '*.xz' -o -name '*.bz2' -o -name '*.old' \) \
  -mtime +"$OLDER_THAN_DAYS" -exec rm -i {} \;
