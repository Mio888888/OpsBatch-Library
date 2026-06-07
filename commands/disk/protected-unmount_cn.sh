#!/usr/bin/env bash
set -euo pipefail

TARGET_MOUNT="${TARGET_MOUNT:-}"
CONFIRM_UMOUNT="${CONFIRM_UMOUNT:-}"

if [ -z "$TARGET_MOUNT" ]; then
  echo "拒绝执行： 请显式设置 TARGET_MOUNT，例如 TARGET_MOUNT=/mnt/data。"
  exit 0
fi

echo "信息：== 当前正在使用 $TARGET_MOUNT =="
if command -v lsof >/dev/null 2>&1; then
  sudo lsof +f -- "$TARGET_MOUNT" 2>/dev/null || lsof +f -- "$TARGET_MOUNT" 2>/dev/null || true
elif command -v fuser >/dev/null 2>&1; then
  sudo fuser -vm "$TARGET_MOUNT" 2>/dev/null || fuser -vm "$TARGET_MOUNT" 2>/dev/null || true
fi

if [ "$CONFIRM_UMOUNT" != "UNMOUNT_TARGET" ]; then
  echo "仅试运行。 请设置 CONFIRM_UMOUNT=UNMOUNT_TARGET ，并仅在确认没有活动工作负载依赖它后卸载。"
  exit 0
fi

if [ "$(uname -s)" = "Darwin" ]; then
  sudo diskutil unmount "$TARGET_MOUNT"
else
  sudo umount "$TARGET_MOUNT"
fi
