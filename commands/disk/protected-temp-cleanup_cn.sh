#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-7}"
CONFIRM_DELETE="${CONFIRM_DELETE:-}"

if [ -z "$TARGET_DIR" ]; then
  echo "拒绝执行： 请显式设置 TARGET_DIR，例如 TARGET_DIR=/tmp。"
  exit 0
fi

if [ "$CONFIRM_DELETE" != "DELETE_TEMP_CANDIDATES" ]; then
  echo "仅试运行。 请设置 CONFIRM_DELETE=DELETE_TEMP_CANDIDATES 以删除匹配文件。"
  find "$TARGET_DIR" -xdev -mindepth 1 -maxdepth 2 -mtime +"$OLDER_THAN_DAYS" -print 2>/dev/null | head -100
  exit 0
fi

echo "信息：正在删除 $TARGET_DIR 中早于 $OLDER_THAN_DAYS 天的候选项。使用前请复核命令和备份。"
find "$TARGET_DIR" -xdev -mindepth 1 -maxdepth 2 -mtime +"$OLDER_THAN_DAYS" -exec rm -ri {} +
