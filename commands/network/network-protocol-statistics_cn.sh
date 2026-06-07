#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v nstat >/dev/null 2>&1; then
    echo "信息：== nstat counters =="
    nstat -az | head -160
  elif command -v netstat >/dev/null 2>&1; then
    echo "信息：== netstat 协议统计 =="
    netstat -s | head -160
  elif [ -r /proc/net/snmp ]; then
    echo "信息：== /proc/net/snmp =="
    cat /proc/net/snmp
  else
    echo "信息：未找到协议统计命令。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "信息：== 协议统计 =="
    netstat -s | head -160
  else
    echo "netstat 不可用."
  fi
else
  echo "未找到受支持的 协议统计命令。"
fi
