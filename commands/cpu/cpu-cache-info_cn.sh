#!/usr/bin/env bash
set -euo pipefail

if command -v lscpu >/dev/null 2>&1; then
  lscpu | grep -E 'cache|L1d|L1i|L2|L3' || true
elif [ "$(uname -s)" = "Linux" ] && ls /sys/devices/system/cpu/cpu0/cache/index* >/dev/null 2>&1; then
  for index in /sys/devices/system/cpu/cpu0/cache/index*; do
    echo "信息：== ${index##*/} =="
    for field in level type size ways_of_associativity coherency_line_size shared_cpu_list; do
      [ -r "$index/$field" ] && echo "信息：$field: $(cat "$index/$field")"
    done
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  sysctl hw.l1icachesize hw.l1dcachesize hw.l2cachesize hw.l3cachesize 2>/dev/null || true
else
  echo "未找到受支持的 CPU 缓存命令。"
fi
