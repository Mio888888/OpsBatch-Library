#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v parted >/dev/null 2>&1; then
    sudo parted -l 2>/dev/null || parted -l 2>/dev/null || true
  elif command -v fdisk >/dev/null 2>&1; then
    sudo fdisk -l 2>/dev/null || fdisk -l 2>/dev/null || true
  else
    echo "信息：Neither parted nor fdisk is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  diskutil list 2>/dev/null || true
else
  echo "未找到受支持的 partition table command found.（No supported partition table command found.）"
fi
