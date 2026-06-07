#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ] && [ -r /proc/interrupts ]; then
  echo "信息：== 按累计次数排序的中断行 =="
  awk '
    NR == 1 { print; next }
    /^[[:space:]]*[0-9]+:/ {
      total = 0
      for (i = 2; i <= NF; i++) {
        if ($i ~ /^[0-9]+$/) total += $i
      }
      print total, $0
    }
  ' /proc/interrupts | sort -nr | head -20
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS 不暴露 /proc/interrupts。改为显示 CPU 和负载摘要。"
  top -l 1 | head -20
else
  echo "未找到受支持的 CPU 中断命令。"
fi
