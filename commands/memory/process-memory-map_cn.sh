#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pid="${PID:-1}"
  echo "信息：Inspecting PID=$pid. Override with PID=<pid> if needed."

  if command -v pmap >/dev/null 2>&1; then
    pmap -x "$pid"
  elif [ -r "/proc/$pid/maps" ]; then
    echo "信息：pmap not installed; showing first 50 lines of /proc/$pid/maps."
    head -50 "/proc/$pid/maps"
  else
    echo "信息：No readable memory map found for PID $pid."
  fi
else
  echo "信息：Process memory maps in this command rely on Linux /proc or pmap output."
fi
