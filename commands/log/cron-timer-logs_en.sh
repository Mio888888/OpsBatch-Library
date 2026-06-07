#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"
PATTERN="${CRON_PATTERN:-cron|crond|CRON|systemd.*timer|Started.*timer|Finished.*timer}"

echo "== cron and timer logs =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    echo "-- journalctl cron/timer entries --"
    journalctl --since "${SINCE:-6 hours ago}" --no-pager 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || true
    echo
  fi
  for file in /var/log/cron /var/log/syslog /var/log/messages; do
    if [ -f "$file" ]; then
      echo "-- $file --"
      grep -Ei "$PATTERN" "$file" 2>/dev/null | tail -n "$LINES" || true
    fi
  done
  if command -v systemctl >/dev/null 2>&1; then
    echo
    echo "-- failed timers --"
    systemctl --failed --type=timer --no-pager 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 6h --style compact --predicate 'process == "cron" OR process == "launchd" OR eventMessage CONTAINS[c] "cron"' 2>/dev/null | tail -n "$LINES" || true
else
  echo "No supported cron/timer log source found."
fi
