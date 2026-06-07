#!/usr/bin/env bash
set -euo pipefail

SINCE="${SINCE:-1 hour ago}"
LINES="${LINES:-120}"

echo "信息：== 从以下时间开始的近期警告/错误日志： $SINCE =="
if [ "$(uname -s)" = "Linux" ] && command -v journalctl >/dev/null 2>&1; then
  journalctl --since "$SINCE" -p warning..alert -n "$LINES" --no-pager 2>/dev/null || echo "信息：journalctl 查询失败；请检查权限或时间表达式。"
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 1h --style compact --predicate 'eventMessage CONTAINS[c] "warning" OR eventMessage CONTAINS[c] "error" OR eventMessage CONTAINS[c] "fail" OR eventMessage CONTAINS[c] "critical" OR eventMessage CONTAINS[c] "panic"' 2>/dev/null | tail -n "$LINES" || true
  echo "信息：macOS 回退方式默认使用 --last 1h；如需精确 SINCE 表达式请手动调整。"
elif [ -f /var/log/system.log ]; then
  grep -Ei 'warning|warn|error|fail|critical|panic' /var/log/system.log 2>/dev/null | tail -n "$LINES" || true
elif [ -f /var/log/syslog ]; then
  grep -Ei 'warning|warn|error|fail|critical|panic' /var/log/syslog 2>/dev/null | tail -n "$LINES" || true
elif [ -f /var/log/messages ]; then
  grep -Ei 'warning|warn|error|fail|critical|panic' /var/log/messages 2>/dev/null | tail -n "$LINES" || true
else
  echo "未找到受支持的 系统日志来源。"
fi
