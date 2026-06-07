#!/usr/bin/env bash
set -euo pipefail

if command -v mpstat >/dev/null 2>&1; then
  mpstat -P ALL 1 1
elif [ -r /proc/stat ]; then
  grep -E '^cpu[0-9]+' /proc/stat | head -64
  echo "信息：Raw per-core /proc/stat jiffies shown; install sysstat for per-core percentages."
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：macOS built-in CLI does not expose simple per-core CPU percentages without privileged powermetrics."
  sysctl hw.ncpu hw.physicalcpu hw.logicalcpu 2>/dev/null || true
  top -l 1 | grep -E '^(CPU usage|Load Avg)' || true
else
  echo "未找到受支持的 per-core CPU command found.（No supported per-core CPU command found.）"
fi
