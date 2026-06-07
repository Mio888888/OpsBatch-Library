#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pid="${PID:-1}"
  echo "信息：Inspecting PID=$pid. Override with PID=<pid> if needed."

  echo
  echo "信息：== ps summary =="
  ps -p "$pid" -o pid,ppid,user,comm,%mem,rss,vsz,etime 2>/dev/null || echo "Process $pid 未找到 by ps.（Process $pid not found by ps.）"

  if [ -r "/proc/$pid/status" ]; then
    echo
    echo "信息：== /proc/$pid/status Vm fields =="
    grep -E '^(Name|State|VmPeak|VmSize|VmLck|VmPin|VmHWM|VmRSS|RssAnon|RssFile|RssShmem|VmData|VmStk|VmExe|VmLib|VmPTE|VmSwap):' "/proc/$pid/status" || true
  else
    echo "信息：/proc/$pid/status is not readable."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  pid="${PID:-1}"
  echo "信息：Inspecting PID=$pid. Override with PID=<pid> if needed."
  ps -p "$pid" -o pid,ppid,user,comm,%mem,rss,vsz,etime 2>/dev/null || echo "Process $pid 未找到 by ps.（Process $pid not found by ps.）"
else
  echo "未找到受支持的 process memory detail command found.（No supported process memory detail command found.）"
fi
