#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-120}"
echo "信息：Inspecting environment for PID=$pid. Override with PID=<pid>; limit rows with PROCESS_LIMIT=<n>."
echo "信息：WARNING: environment variables may contain tokens, secrets, passwords, credentials, or internal endpoints."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/environ" ]; then
    echo
    echo "信息：== /proc/$pid/environ =="
    tr '\0' '\n' < "/proc/$pid/environ" | sort | head -n "$limit"
  else
    echo "Process $pid 未找到 or /proc/$pid/environ is not readable. You may need higher permission.（Process $pid not found or /proc/$pid/environ is not readable. You may need higher permission.）"
  fi
elif command -v ps >/dev/null 2>&1; then
  echo
  echo "信息：== ps environment output =="
  ps eww -p "$pid" 2>/dev/null | head -n "$limit" || echo "信息：Environment is unavailable for PID $pid on this platform."
else
  echo "未找到受支持的 process environment command found.（No supported process environment command found.）"
fi
