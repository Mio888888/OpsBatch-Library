#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "== interface statistics =="
    ip -s link
  elif [ -r /proc/net/dev ]; then
    echo "== /proc/net/dev =="
    cat /proc/net/dev
  elif command -v netstat >/dev/null 2>&1; then
    netstat -i
  else
    echo "No interface statistics command found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "== interface statistics =="
    netstat -ib
  else
    echo "netstat not available."
  fi
else
  echo "No supported interface statistics command found."
fi
