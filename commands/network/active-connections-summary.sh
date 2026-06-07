#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ss >/dev/null 2>&1; then
    echo "== TCP/UDP sockets =="
    ss -tuna

    echo
    echo "== TCP states =="
    ss -tan state all 2>/dev/null | awk 'NR > 1 { count[$1]++ } END { for (state in count) print state, count[state] }' | sort || true
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tunap 2>/dev/null || netstat -tuna
  else
    echo "Neither ss nor netstat is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v netstat >/dev/null 2>&1; then
    echo "== active inet sockets =="
    netstat -an -f inet

    echo
    echo "== TCP states =="
    netstat -an -p tcp | awk 'NR > 2 && $6 != "" { count[$6]++ } END { for (state in count) print state, count[state] }' | sort || true
  else
    echo "netstat not available."
  fi
else
  echo "No supported active connection command found."
fi
