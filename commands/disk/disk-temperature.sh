#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"

if [ "$(uname -s)" = "Linux" ]; then
  if command -v smartctl >/dev/null 2>&1; then
    if [ -n "$TARGET_DEVICE" ]; then
      sudo smartctl -A "$TARGET_DEVICE" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
    elif command -v lsblk >/dev/null 2>&1; then
      for disk in $(lsblk -dn -o NAME 2>/dev/null); do
        echo "== /dev/$disk =="
        sudo smartctl -A "/dev/$disk" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
      done
    else
      echo "Set TARGET_DEVICE, for example TARGET_DEVICE=/dev/sda."
    fi
  else
    echo "smartctl not installed. Install smartmontools to read disk temperature."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS disk temperature usually requires smartctl/smartmontools or vendor tools."
  command -v smartctl >/dev/null 2>&1 && [ -n "$TARGET_DEVICE" ] && smartctl -A "$TARGET_DEVICE" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
else
  echo "No supported disk temperature command found."
fi
