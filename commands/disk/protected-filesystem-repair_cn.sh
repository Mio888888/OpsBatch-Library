#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
CONFIRM_FSCK="${CONFIRM_FSCK:-}"

if [ -z "$TARGET_DEVICE" ]; then
  echo "拒绝执行： 请显式设置 TARGET_DEVICE，例如 TARGET_DEVICE=/dev/sdb1。"
  exit 0
fi

if [ "$CONFIRM_FSCK" != "REPAIR_FILESYSTEM" ]; then
  echo "仅试运行。 请设置 CONFIRM_FSCK=REPAIR_FILESYSTEM ，且仅在确认备份、维护窗口和卸载完成后执行。"
  if [ "$(uname -s)" = "Linux" ] && command -v fsck >/dev/null 2>&1; then
    sudo fsck -N "$TARGET_DEVICE" 2>/dev/null || fsck -N "$TARGET_DEVICE" 2>/dev/null || true
  elif [ "$(uname -s)" = "Darwin" ]; then
    diskutil verifyVolume "$TARGET_DEVICE" 2>/dev/null || true
  fi
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：即将对 $TARGET_DEVICE 运行交互式 fsck。文件系统应已卸载。"
  sudo fsck "$TARGET_DEVICE"
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：即将对 $TARGET_DEVICE 运行 diskutil repairVolume。请确认备份和维护窗口已准备就绪。"
  sudo diskutil repairVolume "$TARGET_DEVICE"
else
  echo "未找到受支持的 文件系统修复命令。"
fi
