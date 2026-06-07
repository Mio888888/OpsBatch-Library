#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：Inspecting resource limits for PID=$pid. Override with PID=<pid> if needed."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/limits" ]; then
    echo "信息：== /proc/$pid/limits =="
    cat "/proc/$pid/limits"
  else
    echo "Process $pid 未找到 or /proc/$pid/limits is not readable.（Process $pid not found or /proc/$pid/limits is not readable.）"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== current shell limits =="
  ulimit -a
  echo
  echo "信息：macOS does not expose another process's full rlimit table through /proc. Use launchctl/ulimit context for the service owner when needed."
  ps -p "$pid" -o pid,ppid,user,comm 2>/dev/null || echo "Process $pid 未找到 by ps.（Process $pid not found by ps.）"
else
  echo "未找到受支持的 process limits command found.（No supported process limits command found.）"
fi
