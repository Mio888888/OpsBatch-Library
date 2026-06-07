#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r /proc/meminfo ]; then
    echo "信息：== MemAvailable 水位线 =="
    awk '
      /^MemTotal:/ { total=$2 }
      /^MemAvailable:/ { available=$2 }
      END {
        if (total > 0 && available > 0) {
          printf "MemAvailable: %.2f GiB / %.2f GiB (%.1f%% 可用)\n", available/1048576, total/1048576, available*100/total
        } else {
          print "未在 /proc/meminfo 中找到 MemAvailable。"
        }
      }
    ' /proc/meminfo

    echo
    echo "信息：== Key pressure fields =="
    grep -E '^(MemTotal|MemFree|MemAvailable|Active|Inactive|Dirty|Writeback|SwapTotal|SwapFree):' /proc/meminfo || true
  else
    echo "/proc/meminfo 不可用。"
  fi

  if command -v vmstat >/dev/null 2>&1; then
    echo
    echo "信息：== vmstat 快照 =="
    vmstat 1 2
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v memory_pressure >/dev/null 2>&1; then
    memory_pressure
  elif command -v vm_stat >/dev/null 2>&1; then
    echo "memory_pressure 不可用；显示 vm_stat 回退信息。"
    vm_stat
  else
    echo "未找到受支持的 macOS 内存压力命令。"
  fi
else
  echo "未找到受支持的 内存压力命令。"
fi
