#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r /proc/meminfo ]; then
    echo "== MemAvailable waterline =="
    awk '
      /^MemTotal:/ { total=$2 }
      /^MemAvailable:/ { available=$2 }
      END {
        if (total > 0 && available > 0) {
          printf "MemAvailable: %.2f GiB / %.2f GiB (%.1f%% available)\n", available/1048576, total/1048576, available*100/total
        } else {
          print "MemAvailable not found in /proc/meminfo."
        }
      }
    ' /proc/meminfo

    echo
    echo "== Key pressure fields =="
    grep -E '^(MemTotal|MemFree|MemAvailable|Active|Inactive|Dirty|Writeback|SwapTotal|SwapFree):' /proc/meminfo || true
  else
    echo "/proc/meminfo is not available."
  fi

  if command -v vmstat >/dev/null 2>&1; then
    echo
    echo "== vmstat snapshot =="
    vmstat 1 2
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v memory_pressure >/dev/null 2>&1; then
    memory_pressure
  elif command -v vm_stat >/dev/null 2>&1; then
    echo "memory_pressure not available; showing vm_stat fallback."
    vm_stat
  else
    echo "No supported macOS memory pressure command found."
  fi
else
  echo "No supported memory pressure command found."
fi
