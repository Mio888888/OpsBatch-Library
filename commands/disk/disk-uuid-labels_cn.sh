#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v blkid >/dev/null 2>&1; then
    sudo blkid 2>/dev/null || blkid 2>/dev/null || true
  elif command -v lsblk >/dev/null 2>&1; then
    lsblk -o NAME,FSTYPE,LABEL,UUID,PARTUUID,MOUNTPOINTS
  else
    echo "信息：Neither blkid nor lsblk is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  diskutil list 2>/dev/null || true
  echo
  diskutil info -all 2>/dev/null | grep -E 'Device Identifier|Volume Name|Volume UUID|Disk / Partition UUID|File System Personality' || true
else
  echo "未找到受支持的 UUID/label command found.（No supported UUID/label command found.）"
fi
