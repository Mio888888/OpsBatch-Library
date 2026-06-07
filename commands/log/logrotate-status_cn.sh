#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_CONFIG="${LOGROTATE_CONFIG:-/etc/logrotate.conf}"
LOGROTATE_STATE="${LOGROTATE_STATE:-/var/lib/logrotate/status}"

echo "信息：== logrotate 可用性 =="
if ! command -v logrotate >/dev/null 2>&1; then
  echo "logrotate command 未找到."
  exit 0
fi
logrotate --version 2>/dev/null | head -5 || true

echo
echo "信息：== logrotate 配置 =="
if [ -f "$LOGROTATE_CONFIG" ]; then
  ls -l "$LOGROTATE_CONFIG" 2>/dev/null || true
  grep -Ev '^[[:space:]]*(#|$)' "$LOGROTATE_CONFIG" 2>/dev/null | head -120 || true
else
  echo "未找到配置： $LOGROTATE_CONFIG"
fi

echo
echo "信息：== logrotate.d 条目 =="
if [ -d /etc/logrotate.d ]; then
  ls -1 /etc/logrotate.d 2>/dev/null | head -100 || true
else
  echo "/etc/logrotate.d 未找到."
fi

echo
echo "信息：== logrotate 状态 =="
if [ -f "$LOGROTATE_STATE" ]; then
  tail -n 80 "$LOGROTATE_STATE" 2>/dev/null || true
else
  echo "未找到状态文件或无法读取： $LOGROTATE_STATE"
fi
