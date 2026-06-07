#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ] && [ -r /proc/interrupts ]; then
  echo "信息：== Top interrupt lines by accumulated count =="
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
  echo "macOS does not expose /proc/interrupts. 正在显示 CPU and load summary instead.（macOS does not expose /proc/interrupts. Showing CPU and load summary instead.）"
  top -l 1 | head -20
else
  echo "未找到受支持的 CPU interrupt command found.（No supported CPU interrupt command found.）"
fi
