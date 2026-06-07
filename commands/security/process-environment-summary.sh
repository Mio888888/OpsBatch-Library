#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-120}"
echo "Inspecting environment for PID=$pid. Override with PID=<pid>; limit rows with PROCESS_LIMIT=<n>."
echo "WARNING: environment variables may contain tokens, secrets, passwords, credentials, or internal endpoints."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/environ" ]; then
    echo
    echo "== /proc/$pid/environ =="
    tr '\0' '\n' < "/proc/$pid/environ" | sort | head -n "$limit"
  else
    echo "Process $pid not found or /proc/$pid/environ is not readable. You may need higher permission."
  fi
elif command -v ps >/dev/null 2>&1; then
  echo
  echo "== ps environment output =="
  ps eww -p "$pid" 2>/dev/null | head -n "$limit" || echo "Environment is unavailable for PID $pid on this platform."
else
  echo "No supported process environment command found."
fi
