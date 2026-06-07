#!/usr/bin/env bash
set -euo pipefail

echo "== zombie processes =="
if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,stat,etime,comm | awk 'NR==1 || $4 ~ /^Z/'
elif ps -eo pid,ppid,user,stat,etime,comm >/dev/null 2>&1; then
  ps -eo pid,ppid,user,stat,etime,comm | awk 'NR==1 || $4 ~ /^Z/'
else
  ps aux | awk 'NR==1 || $8 ~ /^Z/'
fi

echo
echo "If zombies exist, inspect their PPID and parent process behavior; zombies usually need the parent to reap them."
