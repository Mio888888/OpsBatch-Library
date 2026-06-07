#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "运行前请设置 TARGET_DEVICE，例如 /dev/sda。"
  exit 0
fi

if command -v smartctl >/dev/null 2>&1; then
  sudo smartctl -A "$TARGET_DEVICE" 2>/dev/null || smartctl -A "$TARGET_DEVICE" 2>/dev/null || true
else
  echo "信息：未安装 smartctl。请安装 smartmontools 查看 SMART 属性。"
fi
