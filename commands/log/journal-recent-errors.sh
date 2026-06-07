#!/usr/bin/env bash
set -euo pipefail

SINCE="${SINCE:-1 hour ago}"
LINES="${LINES:-120}"

echo "== recent warning/error logs since: $SINCE =="
if [ "$(uname -s)" = "Linux" ] && command -v journalctl >/dev/null 2>&1; then
  journalctl --since "$SINCE" -p warning..alert -n "$LINES" --no-pager 2>/dev/null || echo "journalctl query failed; check permissions or time expression."
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 1h --style compact --predicate 'eventMessage CONTAINS[c] "warning" OR eventMessage CONTAINS[c] "error" OR eventMessage CONTAINS[c] "fail" OR eventMessage CONTAINS[c] "critical" OR eventMessage CONTAINS[c] "panic"' 2>/dev/null | tail -n "$LINES" || true
  echo "macOS fallback uses --last 1h by default; adjust manually for precise SINCE expressions."
elif [ -f /var/log/system.log ]; then
  grep -Ei 'warning|warn|error|fail|critical|panic' /var/log/system.log 2>/dev/null | tail -n "$LINES" || true
elif [ -f /var/log/syslog ]; then
  grep -Ei 'warning|warn|error|fail|critical|panic' /var/log/syslog 2>/dev/null | tail -n "$LINES" || true
elif [ -f /var/log/messages ]; then
  grep -Ei 'warning|warn|error|fail|critical|panic' /var/log/messages 2>/dev/null | tail -n "$LINES" || true
else
  echo "No supported system log source found."
fi
