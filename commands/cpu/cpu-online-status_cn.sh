#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== 在线 CPU 列表 =="
  cat /sys/devices/system/cpu/online 2>/dev/null || true
  echo
  echo "信息：== 离线 CPU 列表 =="
  cat /sys/devices/system/cpu/offline 2>/dev/null || true
  echo
  echo "信息：== 逐 CPU 在线标志 =="
  for file in /sys/devices/system/cpu/cpu*/online; do
    [ -r "$file" ] || continue
    echo "信息：$file=$(cat "$file")"
  done | head -80
elif [ "$(uname -s)" = "Darwin" ]; then
  sysctl hw.ncpu hw.activecpu hw.physicalcpu hw.logicalcpu 2>/dev/null || true
else
  echo "未找到受支持的 CPU 在线状态命令。"
fi
