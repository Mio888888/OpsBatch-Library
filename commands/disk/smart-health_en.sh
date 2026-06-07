#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "Set TARGET_DEVICE before running, for example /dev/sda or disk0."
  if [ "$(uname -s)" = "Linux" ] && command -v lsblk >/dev/null 2>&1; then
    lsblk -d -o NAME,SIZE,MODEL,SERIAL
  elif [ "$(uname -s)" = "Darwin" ]; then
    diskutil list 2>/dev/null || true
  fi
  exit 0
fi

if command -v smartctl >/dev/null 2>&1; then
  sudo smartctl -H "$TARGET_DEVICE" 2>/dev/null || smartctl -H "$TARGET_DEVICE" 2>/dev/null || true
elif [ "$(uname -s)" = "Darwin" ]; then
  diskutil info "$TARGET_DEVICE" 2>/dev/null | grep -E 'SMART Status|Device / Media Name|Disk Size|Protocol' || true
else
  echo "smartctl not installed. Install smartmontools to check SMART health."
fi
