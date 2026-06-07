#!/usr/bin/env bash
set -euo pipefail

echo "信息：Local time: $(date)"
echo "信息：UTC time: $(date -u)"
if command -v timedatectl >/dev/null 2>&1; then
  timedatectl status
elif [ -f /etc/localtime ]; then
  echo "信息：Timezone file: /etc/localtime"
  if command -v readlink >/dev/null 2>&1; then
    readlink /etc/localtime || true
  fi
elif command -v systemsetup >/dev/null 2>&1; then
  systemsetup -gettimezone 2>/dev/null || true
else
  echo "未找到受支持的 timezone detail command found.（No supported timezone detail command found.）"
fi
