#!/usr/bin/env bash
set -euo pipefail

if command -v mpstat >/dev/null 2>&1; then
  mpstat -P ALL 1 1
elif [ -r /proc/stat ]; then
  grep -E '^cpu[0-9]+' /proc/stat | head -64
  echo "信息：已显示原始逐核 /proc/stat jiffies；安装 sysstat 可获取逐核百分比。"
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：没有特权 powermetrics 时，macOS 内置 CLI 不暴露简单的逐核 CPU 百分比。"
  sysctl hw.ncpu hw.physicalcpu hw.logicalcpu 2>/dev/null || true
  top -l 1 | grep -E '^(CPU usage|Load Avg)' || true
else
  echo "未找到受支持的 逐核 CPU命令。"
fi
