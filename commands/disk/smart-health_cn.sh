#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "运行前请设置 TARGET_DEVICE，例如 /dev/sda 或 disk0。"
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
  echo "信息：未安装 smartctl。请安装 smartmontools 检查 SMART 健康状态。"
fi
