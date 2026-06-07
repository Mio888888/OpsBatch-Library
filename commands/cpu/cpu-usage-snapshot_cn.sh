#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Darwin" ] && command -v top >/dev/null 2>&1; then
  top -l 1 | head -20
elif command -v mpstat >/dev/null 2>&1; then
  mpstat 1 1
elif command -v top >/dev/null 2>&1; then
  top -bn1 | head -20
elif [ -r /proc/stat ]; then
  grep '^cpu ' /proc/stat
  echo "信息：已显示原始 /proc/stat jiffies；安装 sysstat 可获取 mpstat 百分比。"
else
  echo "未找到受支持的 CPU 使用率命令。"
fi
