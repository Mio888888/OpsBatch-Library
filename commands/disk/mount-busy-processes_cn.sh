#!/usr/bin/env bash
set -euo pipefail

TARGET_MOUNT="${TARGET_MOUNT:-}"
if [ -z "$TARGET_MOUNT" ]; then
  echo "请设置 TARGET_MOUNT to the mount point before running.（Set TARGET_MOUNT to the mount point before running.）"
  echo "信息：Example: TARGET_MOUNT=/mnt/data sh -c '<this command>'"
  exit 0
fi

if [ ! -e "$TARGET_MOUNT" ]; then
  echo "信息：TARGET_MOUNT does not exist: $TARGET_MOUNT"
  exit 0
fi

echo "信息：== processes using $TARGET_MOUNT =="
if command -v lsof >/dev/null 2>&1; then
  sudo lsof +f -- "$TARGET_MOUNT" 2>/dev/null || lsof +f -- "$TARGET_MOUNT" 2>/dev/null || true
elif command -v fuser >/dev/null 2>&1; then
  sudo fuser -vm "$TARGET_MOUNT" 2>/dev/null || fuser -vm "$TARGET_MOUNT" 2>/dev/null || true
else
  echo "信息：Neither lsof nor fuser is installed."
fi
