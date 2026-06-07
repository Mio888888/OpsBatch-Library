#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "信息：== 接口统计 =="
    ip -s link
  elif [ -r /proc/net/dev ]; then
    echo "信息：== /proc/net/dev =="
    cat /proc/net/dev
  elif command -v netstat >/dev/null 2>&1; then
    netstat -i
  else
    echo "信息：未找到接口统计命令。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "信息：== 接口统计 =="
    netstat -ib
  else
    echo "netstat 不可用."
  fi
else
  echo "未找到受支持的 接口统计命令。"
fi
