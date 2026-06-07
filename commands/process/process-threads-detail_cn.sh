#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-80}"
echo "信息：正在检查 PID=$pid 的线程。可用 PID=<pid> 覆盖；可用 PROCESS_LIMIT=<n> 限制行数。"

if [ "$(uname -s)" = "Linux" ]; then
  if ps -T -p "$pid" -o pid,tid,psr,stat,pri,nice,%cpu,%mem,etime,comm >/dev/null 2>&1; then
    ps -T -p "$pid" -o pid,tid,psr,stat,pri,nice,%cpu,%mem,etime,comm | head -n "$((limit + 1))"
  elif [ -d "/proc/$pid/task" ]; then
    echo "信息：== /proc/$pid/task thread IDs =="
    find "/proc/$pid/task" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sed 's#.*/##' | sort -n | head -n "$limit"
  else
    echo "未找到进程 $pid，或线程详情不可读。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v top >/dev/null 2>&1; then
    top -l 1 -pid "$pid" -stats pid,th,command,cpu,mem,state,time 2>/dev/null | head -n "$limit" || echo "信息：PID $pid 的线程摘要不可用。"
  else
    echo "未找到受支持的 macOS 上的线程详情命令."
  fi
else
  echo "未找到受支持的 process thread detail命令。"
fi
