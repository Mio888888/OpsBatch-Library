#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "运行前请设置 TARGET_DEVICE，例如 TARGET_DEVICE=/dev/sdb1。"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v fsck >/dev/null 2>&1; then
    echo "信息：在支持时以不写入模式运行 fsck。为获得可靠结果，设备应先卸载。"
    sudo fsck -N "$TARGET_DEVICE" 2>/dev/null || fsck -N "$TARGET_DEVICE" 2>/dev/null || true
    sudo fsck -n "$TARGET_DEVICE" 2>/dev/null || fsck -n "$TARGET_DEVICE" 2>/dev/null || true
  else
    echo "信息：未安装 fsck。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  diskutil verifyVolume "$TARGET_DEVICE" 2>/dev/null || true
else
  echo "未找到受支持的 文件系统检查命令。"
fi
