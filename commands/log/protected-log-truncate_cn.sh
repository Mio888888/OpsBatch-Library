#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-}"
CONFIRM_TRUNCATE="${CONFIRM_TRUNCATE:-}"

if [ -z "$LOG_FILE" ]; then
  echo "拒绝执行： 请显式设置 LOG_FILE，例如 LOG_FILE=/var/log/myapp/app.log。"
  exit 0
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "信息：LOG_FILE 不是文件或无法找到： $LOG_FILE"
  exit 0
fi

echo "信息：== 目标日志文件 =="
ls -lh "$LOG_FILE" 2>/dev/null || true
echo
echo "信息：== 截断前最后 20 行 =="
tail -n 20 "$LOG_FILE" 2>/dev/null || true

if [ "$CONFIRM_TRUNCATE" != "TRUNCATE_LOG_FILE" ]; then
  echo
  echo "仅试运行。 请设置 CONFIRM_TRUNCATE=TRUNCATE_LOG_FILE ，并仅在确认写入进程和备份要求后截断此单个文件。"
  exit 0
fi

echo
echo "信息：正在截断 $LOG_FILE。此操作保留文件 inode，但会移除现有内容。"
: > "$LOG_FILE"
ls -lh "$LOG_FILE" 2>/dev/null || true
