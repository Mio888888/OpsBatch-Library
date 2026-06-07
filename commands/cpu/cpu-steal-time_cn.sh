#!/usr/bin/env bash
set -euo pipefail

if command -v mpstat >/dev/null 2>&1; then
  mpstat 1 1 | awk 'NR <= 3 || /all/ { print }'
  echo "提示： %steal 持续偏高通常表示虚拟化宿主机 CPU 争用。"
elif [ "$(uname -s)" = "Linux" ] && command -v top >/dev/null 2>&1; then
  top -bn1 | grep -E '^(%Cpu|Cpu)' || true
  echo "信息：提示：请在 top 输出中查看 st/steal。"
elif [ "$(uname -s)" = "Linux" ] && [ -r /proc/stat ]; then
  grep '^cpu ' /proc/stat
  echo "信息：已显示原始 /proc/stat；Linux 上第 8 个数字字段是以 jiffies 计的 steal 时间。"
else
  echo "信息：CPU steal 时间主要是 Linux 虚拟化指标，此处不暴露。"
fi
