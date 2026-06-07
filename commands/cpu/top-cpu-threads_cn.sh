#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if ps -eLo pid,tid,ppid,user,comm,pcpu,pmem,stat --sort=-pcpu >/dev/null 2>&1; then
    ps -eLo pid,tid,ppid,user,comm,pcpu,pmem,stat --sort=-pcpu | head -15
  elif command -v top >/dev/null 2>&1; then
    top -H -bn1 | head -30
  else
    echo "未找到受支持的 Linux 线程 CPU命令。"
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v top >/dev/null 2>&1; then
  echo "macOS top 显示进程 CPU 和线程数；详细逐线程 CPU 通常需要 Instruments 或特权工具。"
  top -l 1 | head -30
else
  echo "未找到受支持的 线程 CPU命令。"
fi
