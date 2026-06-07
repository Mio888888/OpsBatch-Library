#!/usr/bin/env bash
set -euo pipefail

echo "Local time: $(date)"
echo "UTC time: $(date -u)"
if command -v timedatectl >/dev/null 2>&1; then
  timedatectl status
elif [ -f /etc/localtime ]; then
  echo "Timezone file: /etc/localtime"
  if command -v readlink >/dev/null 2>&1; then
    readlink /etc/localtime || true
  fi
elif command -v systemsetup >/dev/null 2>&1; then
  systemsetup -gettimezone 2>/dev/null || true
else
  echo "No supported timezone detail command found."
fi
