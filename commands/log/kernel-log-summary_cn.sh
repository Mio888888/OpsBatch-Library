#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"
PATTERN="${KERNEL_LOG_PATTERN:-error|fail|warn|panic|segfault|oom|blocked|hung|reset|timeout}"

echo "信息：== 内核日志摘要 =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    echo "信息：-- journalctl -k --"
    journalctl -k -n 1000 --no-pager 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || true
    echo
  fi
  if command -v dmesg >/dev/null 2>&1; then
    echo "信息：-- dmesg --"
    dmesg -T 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || dmesg 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 6h --style compact --predicate 'eventMessage CONTAINS[c] "kernel" OR eventMessage CONTAINS[c] "panic" OR eventMessage CONTAINS[c] "error"' 2>/dev/null | tail -n "$LINES" || true
else
  echo "未找到受支持的 内核日志命令。"
fi
