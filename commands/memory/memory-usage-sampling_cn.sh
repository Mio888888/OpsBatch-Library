#!/usr/bin/env bash
set -euo pipefail

samples="${SAMPLES:-5}"
interval="${INTERVAL:-2}"
echo "信息：正在采样内存使用率：SAMPLES=$samples INTERVAL=${interval}s。需要时可用 SAMPLES=<n> INTERVAL=<seconds> 覆盖。"

if [ "$(uname -s)" = "Linux" ]; then
  i=1
  while [ "$i" -le "$samples" ]; do
    echo "信息：== sample $i $(date '+%Y-%m-%d %H:%M:%S') =="
    if command -v free >/dev/null 2>&1; then
      free -h
    elif [ -r /proc/meminfo ]; then
      grep -E '^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree):' /proc/meminfo || true
    else
      echo "未找到受支持的 Linux 内存来源。"
    fi
    [ "$i" -lt "$samples" ] && sleep "$interval"
    i=$((i + 1))
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  i=1
  while [ "$i" -le "$samples" ]; do
    echo "信息：== sample $i $(date '+%Y-%m-%d %H:%M:%S') =="
    if command -v vm_stat >/dev/null 2>&1; then
      vm_stat
    else
      echo "vm_stat 不可用."
    fi
    [ "$i" -lt "$samples" ] && sleep "$interval"
    i=$((i + 1))
  done
else
  echo "未找到受支持的 内存采样命令。"
fi
