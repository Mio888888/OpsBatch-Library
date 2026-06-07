#!/usr/bin/env bash
set -euo pipefail

limit="${PROCESS_LIMIT:-40}"
echo "正在显示最多 $limit 个进程。需要时可用 PROCESS_LIMIT=<n> 覆盖。"

if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,stat,%cpu,%mem,etime,comm | head -n "$((limit + 1))"
elif ps -eo pid,ppid,user,stat,%cpu,%mem,etime,comm --sort=pid >/dev/null 2>&1; then
  ps -eo pid,ppid,user,stat,%cpu,%mem,etime,comm --sort=pid | head -n "$((limit + 1))"
else
  ps aux | head -n "$((limit + 1))"
fi
