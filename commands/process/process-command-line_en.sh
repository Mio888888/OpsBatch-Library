#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "Inspecting command line for PID=$pid. Override with PID=<pid> if needed."

echo
echo "== ps command =="
ps -p "$pid" -o pid,ppid,user,etime,args 2>/dev/null || echo "Process $pid not found by ps."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/cmdline" ]; then
    echo
    echo "== /proc/$pid/cmdline =="
    tr '\0' ' ' < "/proc/$pid/cmdline"; echo
  else
    echo "/proc/$pid/cmdline is not readable."
  fi
fi
