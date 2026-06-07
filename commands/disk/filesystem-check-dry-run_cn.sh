#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "请设置 TARGET_DEVICE before running, for example TARGET_DEVICE=/dev/sdb1.（Set TARGET_DEVICE before running, for example TARGET_DEVICE=/dev/sdb1.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v fsck >/dev/null 2>&1; then
    echo "信息：Running fsck in no-write mode where supported. Device should be unmounted for reliable results."
    sudo fsck -N "$TARGET_DEVICE" 2>/dev/null || fsck -N "$TARGET_DEVICE" 2>/dev/null || true
    sudo fsck -n "$TARGET_DEVICE" 2>/dev/null || fsck -n "$TARGET_DEVICE" 2>/dev/null || true
  else
    echo "信息：fsck not installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  diskutil verifyVolume "$TARGET_DEVICE" 2>/dev/null || true
else
  echo "未找到受支持的 filesystem check command found.（No supported filesystem check command found.）"
fi
