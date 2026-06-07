#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"
PATTERN="${AUTH_PATTERN:-failed|failure|invalid|authentication error|pam_unix|denied}"

echo "信息：== authentication failure logs =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    journalctl --since "${SINCE:-6 hours ago}" --no-pager 2>/dev/null | grep -Ei "$PATTERN" | grep -Ei 'ssh|sshd|sudo|su|login|pam|polkit|auth' | tail -n "$LINES" || true
    echo
  fi
  for file in /var/log/auth.log /var/log/secure /var/log/messages; do
    if [ -f "$file" ]; then
      echo "信息：-- $file --"
      grep -Ei "$PATTERN" "$file" 2>/dev/null | tail -n "$LINES" || true
    fi
  done
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 6h --style compact --predicate 'eventMessage CONTAINS[c] "authentication" OR eventMessage CONTAINS[c] "failed" OR eventMessage CONTAINS[c] "denied"' 2>/dev/null | tail -n "$LINES" || true
else
  echo "未找到受支持的 authentication log source found.（No supported authentication log source found.）"
fi
