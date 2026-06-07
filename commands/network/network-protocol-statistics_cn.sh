#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v nstat >/dev/null 2>&1; then
    echo "信息：== nstat counters =="
    nstat -az | head -160
  elif command -v netstat >/dev/null 2>&1; then
    echo "信息：== netstat protocol statistics =="
    netstat -s | head -160
  elif [ -r /proc/net/snmp ]; then
    echo "信息：== /proc/net/snmp =="
    cat /proc/net/snmp
  else
    echo "信息：No protocol statistics command found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "信息：== protocol statistics =="
    netstat -s | head -160
  else
    echo "netstat 不可用.（netstat not available.）"
  fi
else
  echo "未找到受支持的 protocol statistics command found.（No supported protocol statistics command found.）"
fi
