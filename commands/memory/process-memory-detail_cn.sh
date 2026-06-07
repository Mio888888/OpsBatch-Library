#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pid="${PID:-1}"
  echo "信息：正在检查 PID=$pid。需要时可用 PID=<pid> 覆盖。"

  echo
  echo "信息：== ps summary =="
  ps -p "$pid" -o pid,ppid,user,comm,%mem,rss,vsz,etime 2>/dev/null || echo "ps 未找到进程 $pid。"

  if [ -r "/proc/$pid/status" ]; then
    echo
    echo "信息：== /proc/$pid/status Vm fields =="
    grep -E '^(Name|State|VmPeak|VmSize|VmLck|VmPin|VmHWM|VmRSS|RssAnon|RssFile|RssShmem|VmData|VmStk|VmExe|VmLib|VmPTE|VmSwap):' "/proc/$pid/status" || true
  else
    echo "信息：/proc/$pid/status 不可读。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  pid="${PID:-1}"
  echo "信息：正在检查 PID=$pid。需要时可用 PID=<pid> 覆盖。"
  ps -p "$pid" -o pid,ppid,user,comm,%mem,rss,vsz,etime 2>/dev/null || echo "ps 未找到进程 $pid。"
else
  echo "未找到受支持的 进程内存详情命令。"
fi
