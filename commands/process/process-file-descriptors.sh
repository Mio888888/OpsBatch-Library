#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-80}"
echo "Inspecting file descriptors for PID=$pid. Override with PID=<pid>; limit rows with PROCESS_LIMIT=<n>."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -d "/proc/$pid/fd" ]; then
    echo "== fd count =="
    find "/proc/$pid/fd" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l | awk '{print $1}'
    echo
    echo "== fd targets =="
    for fd in /proc/"$pid"/fd/*; do
      [ -e "$fd" ] || continue
      printf '%s -> ' "$(basename "$fd")"
      readlink "$fd" 2>/dev/null || echo "not readable"
    done | head -n "$limit"
  else
    echo "Process $pid not found or /proc/$pid/fd is not readable."
  fi
elif command -v lsof >/dev/null 2>&1; then
  echo "== fd list from lsof =="
  lsof -p "$pid" 2>/dev/null | head -n "$limit" || echo "Process $pid not found or lsof needs more permission."
else
  echo "No supported file descriptor command found. Install lsof on macOS."
fi
