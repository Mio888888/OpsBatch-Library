#!/usr/bin/env bash
set -euo pipefail

limit="${PROCESS_LIMIT:-40}"
echo "Showing up to $limit processes. Override with PROCESS_LIMIT=<n> if needed."

if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,stat,%cpu,%mem,etime,comm | head -n "$((limit + 1))"
elif ps -eo pid,ppid,user,stat,%cpu,%mem,etime,comm --sort=pid >/dev/null 2>&1; then
  ps -eo pid,ppid,user,stat,%cpu,%mem,etime,comm --sort=pid | head -n "$((limit + 1))"
else
  ps aux | head -n "$((limit + 1))"
fi
