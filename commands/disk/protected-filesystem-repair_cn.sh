#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
CONFIRM_FSCK="${CONFIRM_FSCK:-}"

if [ -z "$TARGET_DEVICE" ]; then
  echo "拒绝执行： set TARGET_DEVICE explicitly, for example TARGET_DEVICE=/dev/sdb1.（Refusing to run: set TARGET_DEVICE explicitly, for example TARGET_DEVICE=/dev/sdb1.）"
  exit 0
fi

if [ "$CONFIRM_FSCK" != "REPAIR_FILESYSTEM" ]; then
  echo "仅试运行。 请设置 CONFIRM_FSCK=REPAIR_FILESYSTEM only after backups, maintenance window, and unmount are confirmed.（Dry-run only. Set CONFIRM_FSCK=REPAIR_FILESYSTEM only after backups, maintenance window, and unmount are confirmed.）"
  if [ "$(uname -s)" = "Linux" ] && command -v fsck >/dev/null 2>&1; then
    sudo fsck -N "$TARGET_DEVICE" 2>/dev/null || fsck -N "$TARGET_DEVICE" 2>/dev/null || true
  elif [ "$(uname -s)" = "Darwin" ]; then
    diskutil verifyVolume "$TARGET_DEVICE" 2>/dev/null || true
  fi
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：About to run interactive fsck on $TARGET_DEVICE. The filesystem should be unmounted."
  sudo fsck "$TARGET_DEVICE"
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：About to run diskutil repairVolume on $TARGET_DEVICE. Ensure backups and maintenance window are ready."
  sudo diskutil repairVolume "$TARGET_DEVICE"
else
  echo "未找到受支持的 filesystem repair command found.（No supported filesystem repair command found.）"
fi
