#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"

if [ "$(uname -s)" = "Linux" ]; then
  if command -v smartctl >/dev/null 2>&1; then
    if [ -n "$TARGET_DEVICE" ]; then
      sudo smartctl -A "$TARGET_DEVICE" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
    elif command -v lsblk >/dev/null 2>&1; then
      for disk in $(lsblk -dn -o NAME 2>/dev/null); do
        echo "信息：== /dev/$disk =="
        sudo smartctl -A "/dev/$disk" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
      done
    else
      echo "请设置 TARGET_DEVICE, for example TARGET_DEVICE=/dev/sda.（Set TARGET_DEVICE, for example TARGET_DEVICE=/dev/sda.）"
    fi
  else
    echo "信息：smartctl not installed. Install smartmontools to read disk temperature."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS disk temperature usually 需要 smartctl/smartmontools or vendor tools.（macOS disk temperature usually requires smartctl/smartmontools or vendor tools.）"
  command -v smartctl >/dev/null 2>&1 && [ -n "$TARGET_DEVICE" ] && smartctl -A "$TARGET_DEVICE" 2>/dev/null | grep -Ei 'Temperature|Airflow|194|190' || true
else
  echo "未找到受支持的 disk temperature command found.（No supported disk temperature command found.）"
fi
