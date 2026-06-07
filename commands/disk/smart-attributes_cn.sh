#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "请设置 TARGET_DEVICE before running, for example /dev/sda.（Set TARGET_DEVICE before running, for example /dev/sda.）"
  exit 0
fi

if command -v smartctl >/dev/null 2>&1; then
  sudo smartctl -A "$TARGET_DEVICE" 2>/dev/null || smartctl -A "$TARGET_DEVICE" 2>/dev/null || true
else
  echo "信息：smartctl not installed. Install smartmontools to view SMART attributes."
fi
