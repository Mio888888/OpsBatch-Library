#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "Inspecting resource limits for PID=$pid. Override with PID=<pid> if needed."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/limits" ]; then
    echo "== /proc/$pid/limits =="
    cat "/proc/$pid/limits"
  else
    echo "Process $pid not found or /proc/$pid/limits is not readable."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "== current shell limits =="
  ulimit -a
  echo
  echo "macOS does not expose another process's full rlimit table through /proc. Use launchctl/ulimit context for the service owner when needed."
  ps -p "$pid" -o pid,ppid,user,comm 2>/dev/null || echo "Process $pid not found by ps."
else
  echo "No supported process limits command found."
fi
