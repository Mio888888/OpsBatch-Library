#!/usr/bin/env bash
set -euo pipefail

SINCE="${SINCE:-1 hour ago}"
UNTIL="${UNTIL:-now}"
LINES="${LINES:-200}"
LOG_PATTERN="${LOG_PATTERN:-}"

echo "信息：== logs from $SINCE to $UNTIL =="
if command -v journalctl >/dev/null 2>&1; then
  if [ -n "$LOG_PATTERN" ]; then
    journalctl --since "$SINCE" --until "$UNTIL" --no-pager 2>/dev/null | grep -Ei "$LOG_PATTERN" | tail -n "$LINES" || true
  else
    journalctl --since "$SINCE" --until "$UNTIL" -n "$LINES" --no-pager 2>/dev/null || echo "信息：journalctl query failed; check permissions or time expression."
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  if [ -n "$LOG_PATTERN" ]; then
    log show --last 1h --style compact 2>/dev/null | grep -Ei "$LOG_PATTERN" | tail -n "$LINES" || true
    echo "信息：macOS fallback uses --last 1h; use predicate options manually for precise absolute time ranges."
  else
    log show --last 1h --style compact 2>/dev/null | tail -n "$LINES" || true
    echo "信息：macOS fallback uses --last 1h; use predicate options manually for precise absolute time ranges."
  fi
else
  echo "未找到受支持的 time-range log source found.（No supported time-range log source found.）"
fi
