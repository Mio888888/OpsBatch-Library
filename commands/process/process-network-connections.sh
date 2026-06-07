#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-120}"
echo "Inspecting network connections for PID=$pid. Override with PID=<pid>; limit rows with PROCESS_LIMIT=<n>."

if command -v lsof >/dev/null 2>&1; then
  echo "== network sockets from lsof =="
  lsof -nP -a -p "$pid" -iTCP -iUDP 2>/dev/null | head -n "$limit" || echo "No sockets found or lsof needs more permission."
elif [ "$(uname -s)" = "Linux" ] && command -v ss >/dev/null 2>&1; then
  echo "== sockets with process info from ss =="
  ss -tunap 2>/dev/null | { head -1; grep -F "pid=$pid," || true; } | head -n "$limit"
elif command -v netstat >/dev/null 2>&1; then
  echo "== sockets from netstat (process mapping may be unavailable) =="
  netstat -an 2>/dev/null | head -n "$limit"
else
  echo "No supported process network command found. Install lsof or iproute2."
fi
