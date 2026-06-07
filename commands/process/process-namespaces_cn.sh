#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：正在检查 PID=$pid 的命名空间。需要时可用 PID=<pid> 覆盖。"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -d "/proc/$pid/ns" ]; then
    echo "信息：== /proc/$pid/ns =="
    for ns in /proc/"$pid"/ns/*; do
      [ -e "$ns" ] || continue
      printf '%s -> ' "$(basename "$ns")"
      readlink "$ns" 2>/dev/null || echo "信息：不可读"
    done | sort
    echo
    echo "信息：比较不同进程的命名空间 inode 值，以识别共享或隔离的命名空间。"
  else
    echo "Process $pid 未找到 or /proc/$pid/ns is 不可读."
  fi
else
  echo "Linux namespace 在当前平台不可用： $(uname -s)."
fi
