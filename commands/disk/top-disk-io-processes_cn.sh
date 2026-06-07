#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v iotop >/dev/null 2>&1; then
    sudo iotop -b -n 3 -o 2>/dev/null || iotop -b -n 3 -o 2>/dev/null || true
  elif command -v pidstat >/dev/null 2>&1; then
    pidstat -d 1 3
  else
    echo "信息：Neither iotop nor pidstat is installed. Install iotop or sysstat for per-process I/O details."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v fs_usage >/dev/null 2>&1; then
    echo "fs_usage usually 需要 sudo; sampling for 5 seconds.（fs_usage usually requires sudo; sampling for 5 seconds.）"
    sudo fs_usage -w -f filesys 2>/dev/null | head -80 || true
  else
    echo "fs_usage 不可用.（fs_usage not available.）"
  fi
else
  echo "未找到受支持的 per-process disk I/O command found.（No supported per-process disk I/O command found.）"
fi
