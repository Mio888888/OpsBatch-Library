#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v nstat >/dev/null 2>&1; then
    echo "== nstat counters =="
    nstat -az | head -160
  elif command -v netstat >/dev/null 2>&1; then
    echo "== netstat protocol statistics =="
    netstat -s | head -160
  elif [ -r /proc/net/snmp ]; then
    echo "== /proc/net/snmp =="
    cat /proc/net/snmp
  else
    echo "No protocol statistics command found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "== protocol statistics =="
    netstat -s | head -160
  else
    echo "netstat not available."
  fi
else
  echo "No supported protocol statistics command found."
fi
