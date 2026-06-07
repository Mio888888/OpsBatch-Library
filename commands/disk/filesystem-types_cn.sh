#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== mounted filesystems =="
  if command -v findmnt >/dev/null 2>&1; then
    findmnt -o TARGET,SOURCE,FSTYPE,SIZE,USED,AVAIL,USE%,OPTIONS
  else
    df -Th
  fi

  echo
  echo "信息：== known block device filesystems =="
  if command -v lsblk >/dev/null 2>&1; then
    lsblk -f
  elif command -v blkid >/dev/null 2>&1; then
    sudo blkid 2>/dev/null || blkid 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== mounted filesystems =="
  df -Th 2>/dev/null || df -h
  echo
  diskutil list 2>/dev/null || true
else
  echo "未找到受支持的 filesystem type command found.（No supported filesystem type command found.）"
fi
