#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-/tmp}"
OLDER_THAN_DAYS="${OLDER_THAN_DAYS:-7}"

echo "信息：== 清理候选项目录： $TARGET_DIR older than $OLDER_THAN_DAYS days =="
if [ -d "$TARGET_DIR" ]; then
  find "$TARGET_DIR" -xdev -mindepth 1 -mtime +"$OLDER_THAN_DAYS" -maxdepth 2 -print 2>/dev/null | head -100
  echo
  echo "信息：此命令只列出候选项，不会删除任何内容。清理前请复核所有者和活动进程。"
else
  echo "信息：TARGET_DIR 不是目录: $TARGET_DIR"
fi
