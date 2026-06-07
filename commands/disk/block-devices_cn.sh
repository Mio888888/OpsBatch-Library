#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v lsblk >/dev/null 2>&1; then
    lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS
  else
    echo "信息：未安装 lsblk；回退到 /proc/partitions。"
    cat /proc/partitions 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v diskutil >/dev/null 2>&1; then
    diskutil list
  else
    echo "diskutil 不可用。"
  fi
else
  echo "未找到受支持的 块设备命令。"
fi
