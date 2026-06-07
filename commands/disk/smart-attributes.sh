#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "Set TARGET_DEVICE before running, for example /dev/sda."
  exit 0
fi

if command -v smartctl >/dev/null 2>&1; then
  sudo smartctl -A "$TARGET_DEVICE" 2>/dev/null || smartctl -A "$TARGET_DEVICE" 2>/dev/null || true
else
  echo "smartctl not installed. Install smartmontools to view SMART attributes."
fi
