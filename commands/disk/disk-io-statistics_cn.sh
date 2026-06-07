#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v iostat >/dev/null 2>&1; then
    iostat -xz 1 3
  else
    echo "信息：未安装 iostat。请安装 sysstat 以收集逐设备 I/O 统计。"
    echo
    echo "信息：== /proc/diskstats 快照 =="
    cat /proc/diskstats 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v iostat >/dev/null 2>&1; then
    iostat -d -w 1 -c 3
  else
    echo "iostat 不可用。"
  fi
else
  echo "未找到受支持的 磁盘 I/O 统计命令。"
fi
