#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-}"
LINES="${LINES:-120}"

if [ -z "$LOG_FILE" ]; then
  echo "拒绝执行： 请显式设置 LOG_FILE，例如 LOG_FILE=/var/log/app/app.log。"
  exit 0
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "信息：LOG_FILE 不是文件或无法找到： $LOG_FILE"
  exit 0
fi

echo "信息：== 从 $LOG_FILE 读取最后 $LINES 行 =="
tail -n "$LINES" "$LOG_FILE" 2>/dev/null || echo "无法读取 $LOG_FILE; 请检查权限。"
