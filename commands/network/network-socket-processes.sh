#!/usr/bin/env bash
set -euo pipefail

if command -v lsof >/dev/null 2>&1; then
  echo "== network sockets by process =="
  lsof -nP -iTCP -iUDP 2>/dev/null | head -120 || true
elif [ "$(uname -s)" = "Linux" ] && command -v ss >/dev/null 2>&1; then
  echo "== sockets with process info =="
  ss -tulpen 2>/dev/null || ss -tuln
elif command -v netstat >/dev/null 2>&1; then
  echo "== sockets =="
  netstat -tunap 2>/dev/null || netstat -tuna 2>/dev/null || netstat -an
else
  echo "No supported socket/process command found. Install lsof or iproute2."
fi
