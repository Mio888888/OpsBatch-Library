#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"
PATTERN="${CRON_PATTERN:-cron|crond|CRON|systemd.*timer|Started.*timer|Finished.*timer}"

echo "信息：== cron and timer logs =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    echo "信息：-- journalctl cron/timer entries --"
    journalctl --since "${SINCE:-6 hours ago}" --no-pager 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || true
    echo
  fi
  for file in /var/log/cron /var/log/syslog /var/log/messages; do
    if [ -f "$file" ]; then
      echo "信息：-- $file --"
      grep -Ei "$PATTERN" "$file" 2>/dev/null | tail -n "$LINES" || true
    fi
  done
  if command -v systemctl >/dev/null 2>&1; then
    echo
    echo "信息：-- failed timers --"
    systemctl --failed --type=timer --no-pager 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 6h --style compact --predicate 'process == "cron" OR process == "launchd" OR eventMessage CONTAINS[c] "cron"' 2>/dev/null | tail -n "$LINES" || true
else
  echo "未找到受支持的 cron/timer log source found.（No supported cron/timer log source found.）"
fi
