#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-160}"
SINCE="${SINCE:-12 hours ago}"
PATTERN="${SECURITY_LOG_PATTERN:-failed|failure|invalid|denied|sudo|su:|sshd|pam|polkit|segfault|audit|apparmor|selinux|firewall|blocked}"

echo "== security timeline since: $SINCE =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    journalctl --since "$SINCE" --no-pager 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || true
    echo
  fi
  for file in /var/log/auth.log /var/log/secure /var/log/audit/audit.log /var/log/messages /var/log/syslog; do
    if [ -f "$file" ]; then
      echo "-- $file --"
      grep -Ei "$PATTERN" "$file" 2>/dev/null | tail -n "$LINES" || true
    fi
  done
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last "${MACOS_LAST:-12h}" --style compact --predicate 'eventMessage CONTAINS[c] "failed" OR eventMessage CONTAINS[c] "denied" OR eventMessage CONTAINS[c] "sudo" OR eventMessage CONTAINS[c] "ssh" OR eventMessage CONTAINS[c] "authorization"' 2>/dev/null | tail -n "$LINES" || true
else
  echo "No supported security log source found."
fi
