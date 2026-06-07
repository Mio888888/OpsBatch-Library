#!/usr/bin/env bash
set -euo pipefail

if command -v mpstat >/dev/null 2>&1; then
  mpstat 1 1 | awk 'NR <= 3 || /all/ { print }'
  echo "Hint: %steal 持续偏高通常表示虚拟化宿主机 CPU 争用。"
elif [ "$(uname -s)" = "Linux" ] && command -v top >/dev/null 2>&1; then
  top -bn1 | grep -E '^(%Cpu|Cpu)' || true
  echo "Hint: look for st/steal in top output."
elif [ "$(uname -s)" = "Linux" ] && [ -r /proc/stat ]; then
  grep '^cpu ' /proc/stat
  echo "Raw /proc/stat shown; the 8th numeric field is steal time in jiffies on Linux."
else
  echo "CPU steal time is primarily a Linux virtualization metric and is not exposed here."
fi
