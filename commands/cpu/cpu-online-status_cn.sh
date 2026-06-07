#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== Online CPU list =="
  cat /sys/devices/system/cpu/online 2>/dev/null || true
  echo
  echo "信息：== Offline CPU list =="
  cat /sys/devices/system/cpu/offline 2>/dev/null || true
  echo
  echo "信息：== Per-CPU online flags =="
  for file in /sys/devices/system/cpu/cpu*/online; do
    [ -r "$file" ] || continue
    echo "信息：$file=$(cat "$file")"
  done | head -80
elif [ "$(uname -s)" = "Darwin" ]; then
  sysctl hw.ncpu hw.activecpu hw.physicalcpu hw.logicalcpu 2>/dev/null || true
else
  echo "未找到受支持的 CPU online-status command found.（No supported CPU online-status command found.）"
fi
