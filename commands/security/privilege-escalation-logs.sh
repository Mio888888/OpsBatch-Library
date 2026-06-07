#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"
PATTERN="${PRIVILEGE_PATTERN:-sudo|su:|polkit|pkexec|authentication failure|session opened|session closed|COMMAND=}"

echo "== sudo / privilege escalation logs =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    journalctl --since "${SINCE:-6 hours ago}" --no-pager 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || true
    echo
  fi
  for file in /var/log/auth.log /var/log/secure /var/log/messages; do
    if [ -f "$file" ]; then
      echo "-- $file --"
      grep -Ei "$PATTERN" "$file" 2>/dev/null | tail -n "$LINES" || true
    fi
  done
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 6h --style compact --predicate 'eventMessage CONTAINS[c] "sudo" OR eventMessage CONTAINS[c] "authorization" OR eventMessage CONTAINS[c] "authentication"' 2>/dev/null | tail -n "$LINES" || true
else
  echo "No supported privilege log source found."
fi
