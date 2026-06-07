#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pid="${PID:-1}"
  echo "Inspecting PID=$pid. Override with PID=<pid> if needed."

  echo
  echo "== ps summary =="
  ps -p "$pid" -o pid,ppid,user,comm,%mem,rss,vsz,etime 2>/dev/null || echo "Process $pid not found by ps."

  if [ -r "/proc/$pid/status" ]; then
    echo
    echo "== /proc/$pid/status Vm fields =="
    grep -E '^(Name|State|VmPeak|VmSize|VmLck|VmPin|VmHWM|VmRSS|RssAnon|RssFile|RssShmem|VmData|VmStk|VmExe|VmLib|VmPTE|VmSwap):' "/proc/$pid/status" || true
  else
    echo "/proc/$pid/status is not readable."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  pid="${PID:-1}"
  echo "Inspecting PID=$pid. Override with PID=<pid> if needed."
  ps -p "$pid" -o pid,ppid,user,comm,%mem,rss,vsz,etime 2>/dev/null || echo "Process $pid not found by ps."
else
  echo "No supported process memory detail command found."
fi
