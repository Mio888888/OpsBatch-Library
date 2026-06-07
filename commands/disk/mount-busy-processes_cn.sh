#!/usr/bin/env bash
set -euo pipefail

TARGET_MOUNT="${TARGET_MOUNT:-}"
if [ -z "$TARGET_MOUNT" ]; then
  echo "运行前请将 TARGET_MOUNT 设置为挂载点。"
  echo "信息：示例： TARGET_MOUNT=/mnt/data sh -c '<this command>'"
  exit 0
fi

if [ ! -e "$TARGET_MOUNT" ]; then
  echo "信息：TARGET_MOUNT 不存在: $TARGET_MOUNT"
  exit 0
fi

echo "信息：== 正在使用的进程： $TARGET_MOUNT =="
if command -v lsof >/dev/null 2>&1; then
  sudo lsof +f -- "$TARGET_MOUNT" 2>/dev/null || lsof +f -- "$TARGET_MOUNT" 2>/dev/null || true
elif command -v fuser >/dev/null 2>&1; then
  sudo fuser -vm "$TARGET_MOUNT" 2>/dev/null || fuser -vm "$TARGET_MOUNT" 2>/dev/null || true
else
  echo "信息：未安装 lsof 和 fuser。"
fi
