#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-80}"
echo "Inspecting threads for PID=$pid. Override with PID=<pid>; limit rows with PROCESS_LIMIT=<n>."

if [ "$(uname -s)" = "Linux" ]; then
  if ps -T -p "$pid" -o pid,tid,psr,stat,pri,nice,%cpu,%mem,etime,comm >/dev/null 2>&1; then
    ps -T -p "$pid" -o pid,tid,psr,stat,pri,nice,%cpu,%mem,etime,comm | head -n "$((limit + 1))"
  elif [ -d "/proc/$pid/task" ]; then
    echo "== /proc/$pid/task thread IDs =="
    find "/proc/$pid/task" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sed 's#.*/##' | sort -n | head -n "$limit"
  else
    echo "Process $pid not found or thread details are not readable."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v top >/dev/null 2>&1; then
    top -l 1 -pid "$pid" -stats pid,th,command,cpu,mem,state,time 2>/dev/null | head -n "$limit" || echo "Thread summary unavailable for PID $pid."
  else
    echo "No supported thread detail command found on macOS."
  fi
else
  echo "No supported process thread detail command found."
fi
