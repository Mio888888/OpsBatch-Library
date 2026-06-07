#!/usr/bin/env bash
set -euo pipefail

LINES="${LINES:-120}"
PATTERN="${SSH_LOG_PATTERN:-sshd|Accepted|Failed|Invalid user|Disconnected|Connection closed|authentication failure}"

echo "信息：== SSH login logs =="
if [ "$(uname -s)" = "Linux" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    journalctl --since "${SINCE:-6 hours ago}" --no-pager 2>/dev/null | grep -Ei "$PATTERN" | tail -n "$LINES" || true
    echo
  fi
  for file in /var/log/auth.log /var/log/secure /var/log/messages; do
    if [ -f "$file" ]; then
      echo "信息：-- $file --"
      grep -Ei "$PATTERN" "$file" 2>/dev/null | tail -n "$LINES" || true
    fi
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  if [ -f /var/log/system.log ]; then
    grep -Ei "$PATTERN" /var/log/system.log 2>/dev/null | tail -n "$LINES" || true
  elif command -v log >/dev/null 2>&1; then
    log show --last 6h --style compact --predicate 'process == "sshd" OR eventMessage CONTAINS[c] "ssh"' 2>/dev/null | tail -n "$LINES" || true
  fi
else
  echo "未找到受支持的 SSH 日志来源。"
fi
