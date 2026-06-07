#!/usr/bin/env bash
set -euo pipefail

TARGET_MOUNT="${TARGET_MOUNT:-}"
CONFIRM_UMOUNT="${CONFIRM_UMOUNT:-}"

if [ -z "$TARGET_MOUNT" ]; then
  echo "拒绝执行： set TARGET_MOUNT explicitly, for example TARGET_MOUNT=/mnt/data.（Refusing to run: set TARGET_MOUNT explicitly, for example TARGET_MOUNT=/mnt/data.）"
  exit 0
fi

echo "信息：== processes currently using $TARGET_MOUNT =="
if command -v lsof >/dev/null 2>&1; then
  sudo lsof +f -- "$TARGET_MOUNT" 2>/dev/null || lsof +f -- "$TARGET_MOUNT" 2>/dev/null || true
elif command -v fuser >/dev/null 2>&1; then
  sudo fuser -vm "$TARGET_MOUNT" 2>/dev/null || fuser -vm "$TARGET_MOUNT" 2>/dev/null || true
fi

if [ "$CONFIRM_UMOUNT" != "UNMOUNT_TARGET" ]; then
  echo "仅试运行。 请设置 CONFIRM_UMOUNT=UNMOUNT_TARGET to unmount 在确认后 no active workload depends on it.（Dry-run only. Set CONFIRM_UMOUNT=UNMOUNT_TARGET to unmount after confirming no active workload depends on it.）"
  exit 0
fi

if [ "$(uname -s)" = "Darwin" ]; then
  sudo diskutil unmount "$TARGET_MOUNT"
else
  sudo umount "$TARGET_MOUNT"
fi
