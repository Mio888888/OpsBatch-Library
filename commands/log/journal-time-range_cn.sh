#!/usr/bin/env bash
set -euo pipefail

SINCE="${SINCE:-1 hour ago}"
UNTIL="${UNTIL:-now}"
LINES="${LINES:-200}"
LOG_PATTERN="${LOG_PATTERN:-}"

echo "信息：== 从 $SINCE 到 $UNTIL 的日志 =="
if command -v journalctl >/dev/null 2>&1; then
  if [ -n "$LOG_PATTERN" ]; then
    journalctl --since "$SINCE" --until "$UNTIL" --no-pager 2>/dev/null | grep -Ei "$LOG_PATTERN" | tail -n "$LINES" || true
  else
    journalctl --since "$SINCE" --until "$UNTIL" -n "$LINES" --no-pager 2>/dev/null || echo "信息：journalctl 查询失败；请检查权限或时间表达式。"
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  if [ -n "$LOG_PATTERN" ]; then
    log show --last 1h --style compact 2>/dev/null | grep -Ei "$LOG_PATTERN" | tail -n "$LINES" || true
    echo "信息：macOS 回退方式使用 --last 1h；如需精确绝对时间范围请手动使用 predicate 选项。"
  else
    log show --last 1h --style compact 2>/dev/null | tail -n "$LINES" || true
    echo "信息：macOS 回退方式使用 --last 1h；如需精确绝对时间范围请手动使用 predicate 选项。"
  fi
else
  echo "未找到受支持的 时间范围日志来源。"
fi
