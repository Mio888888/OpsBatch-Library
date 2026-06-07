#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_CONFIG="${LOGROTATE_CONFIG:-/etc/logrotate.conf}"
LOGROTATE_STATE="${LOGROTATE_STATE:-/var/lib/logrotate/status}"

echo "信息：== logrotate availability =="
if ! command -v logrotate >/dev/null 2>&1; then
  echo "logrotate command 未找到.（logrotate command not found.）"
  exit 0
fi
logrotate --version 2>/dev/null | head -5 || true

echo
echo "信息：== logrotate config =="
if [ -f "$LOGROTATE_CONFIG" ]; then
  ls -l "$LOGROTATE_CONFIG" 2>/dev/null || true
  grep -Ev '^[[:space:]]*(#|$)' "$LOGROTATE_CONFIG" 2>/dev/null | head -120 || true
else
  echo "Config 未找到: $LOGROTATE_CONFIG（Config not found: $LOGROTATE_CONFIG）"
fi

echo
echo "信息：== logrotate.d entries =="
if [ -d /etc/logrotate.d ]; then
  ls -1 /etc/logrotate.d 2>/dev/null | head -100 || true
else
  echo "/etc/logrotate.d 未找到.（/etc/logrotate.d not found.）"
fi

echo
echo "信息：== logrotate state =="
if [ -f "$LOGROTATE_STATE" ]; then
  tail -n 80 "$LOGROTATE_STATE" 2>/dev/null || true
else
  echo "State file 未找到 or unreadable: $LOGROTATE_STATE（State file not found or unreadable: $LOGROTATE_STATE）"
fi
