#!/usr/bin/env bash
set -euo pipefail

echo "== uninterruptible sleep / D-state processes =="
if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,stat,etime,comm,wchan 2>/dev/null | awk 'NR==1 || $4 ~ /^D/'
elif ps -eo pid,ppid,user,stat,etime,comm,wchan >/dev/null 2>&1; then
  ps -eo pid,ppid,user,stat,etime,comm,wchan | awk 'NR==1 || $4 ~ /^D/'
else
  ps aux | awk 'NR==1 || $8 ~ /^D/'
fi

echo
echo "D-state often points to blocked I/O, filesystem, device, or kernel wait paths. Correlate with disk/network/kernel logs."
