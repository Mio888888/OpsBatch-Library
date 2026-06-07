#!/usr/bin/env bash
set -euo pipefail

limit="${PROCESS_LIMIT:-30}"
echo "Showing top $limit long-running processes. Override with PROCESS_LIMIT=<n> if needed."

if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,lstart,etime,comm | head -n "$((limit + 1))"
elif ps -eo pid,ppid,user,lstart,etime,comm --sort=start_time >/dev/null 2>&1; then
  ps -eo pid,ppid,user,lstart,etime,comm --sort=start_time | head -n "$((limit + 1))"
else
  ps aux | awk 'NR==1 || NR<=31'
fi

echo
echo "Long-running processes are not necessarily abnormal; compare with expected service lifetimes and deployment history."
