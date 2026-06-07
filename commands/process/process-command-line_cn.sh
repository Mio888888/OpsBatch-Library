#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：正在检查 PID=$pid 的命令行。需要时可用 PID=<pid> 覆盖。"

echo
echo "信息：== ps command =="
ps -p "$pid" -o pid,ppid,user,etime,args 2>/dev/null || echo "ps 未找到进程 $pid。"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/cmdline" ]; then
    echo
    echo "信息：== /proc/$pid/cmdline =="
    tr '\0' ' ' < "/proc/$pid/cmdline"; echo
  else
    echo "信息：/proc/$pid/cmdline is 不可读."
  fi
fi
