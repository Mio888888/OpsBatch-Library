#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== free -h =="
  if command -v free >/dev/null 2>&1; then
    free -h
  else
    echo "信息：free not installed; showing key /proc/meminfo fields."
  fi

  if [ -r /proc/meminfo ]; then
    echo
    echo "信息：== /proc/meminfo key fields =="
    grep -E '^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SReclaimable|Shmem|SwapTotal|SwapFree):' /proc/meminfo || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== vm_stat =="
  if command -v vm_stat >/dev/null 2>&1; then
    vm_stat
  else
    echo "vm_stat 不可用.（vm_stat not available.）"
  fi

  echo
  echo "信息：== memory size =="
  sysctl hw.memsize 2>/dev/null || true
else
  echo "未找到受支持的 memory summary command found.（No supported memory summary command found.）"
fi
