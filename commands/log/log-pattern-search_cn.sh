#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-}"
LOG_PATTERN="${LOG_PATTERN:-error|fail|exception|timeout|critical}"
LINES="${LINES:-120}"

if [ -z "$LOG_FILE" ]; then
  echo "拒绝执行： 请显式设置 LOG_FILE，例如 LOG_FILE=/var/log/app/app.log。"
  exit 0
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "信息：LOG_FILE 不是文件或无法找到： $LOG_FILE"
  exit 0
fi

echo "信息：== 在 $LOG_FILE 中搜索模式 =="
echo "信息：模式： $LOG_PATTERN"
grep -Ein "$LOG_PATTERN" "$LOG_FILE" 2>/dev/null | tail -n "$LINES" || echo "信息：未找到匹配项或无法读取文件。"
