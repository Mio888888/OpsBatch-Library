#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "信息：== interface statistics =="
    ip -s link
  elif [ -r /proc/net/dev ]; then
    echo "信息：== /proc/net/dev =="
    cat /proc/net/dev
  elif command -v netstat >/dev/null 2>&1; then
    netstat -i
  else
    echo "信息：No interface statistics command found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "信息：== interface statistics =="
    netstat -ib
  else
    echo "netstat 不可用.（netstat not available.）"
  fi
else
  echo "未找到受支持的 interface statistics command found.（No supported interface statistics command found.）"
fi
