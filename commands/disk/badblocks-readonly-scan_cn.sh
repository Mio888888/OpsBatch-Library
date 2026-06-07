#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "运行前请设置 TARGET_DEVICE，例如 TARGET_DEVICE=/dev/sdb。"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v badblocks >/dev/null 2>&1; then
    echo "信息：正在运行只读 badblocks 扫描。这可能耗时很久，请谨慎安排执行时间。"
    sudo badblocks -sv "$TARGET_DEVICE"
  else
    echo "信息：未安装 badblocks。"
  fi
else
  echo "信息：此命令中的 badblocks 扫描仅适用于 Linux。"
fi
