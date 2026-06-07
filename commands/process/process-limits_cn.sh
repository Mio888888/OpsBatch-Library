#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：正在检查 PID=$pid 的资源限制。需要时可用 PID=<pid> 覆盖。"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/limits" ]; then
    echo "信息：== /proc/$pid/limits =="
    cat "/proc/$pid/limits"
  else
    echo "Process $pid 未找到 or /proc/$pid/limits 不可读。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== 当前 shell 限制 =="
  ulimit -a
  echo
  echo "信息：macOS 不会通过 /proc 暴露其他进程的完整 rlimit 表。需要时请使用服务所有者的 launchctl/ulimit 上下文。"
  ps -p "$pid" -o pid,ppid,user,comm 2>/dev/null || echo "ps 未找到进程 $pid。"
else
  echo "未找到受支持的 process limits命令。"
fi
