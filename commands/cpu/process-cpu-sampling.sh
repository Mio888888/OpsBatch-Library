#!/usr/bin/env bash
set -euo pipefail

if command -v pidstat >/dev/null 2>&1; then
  pidstat -u 1 3
elif [ "$(uname -s)" = "Linux" ]; then
  echo "pidstat not installed; showing three ps snapshots sorted by CPU."
  for i in 1 2 3; do
    echo "== snapshot $i =="
    if ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu >/dev/null 2>&1; then
      ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu | head -11
    else
      ps aux | sort -nrk 3 | head -10
    fi
    [ "$i" -lt 3 ] && sleep 1
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "Showing three macOS ps snapshots sorted by CPU."
  for i in 1 2 3; do
    echo "== snapshot $i =="
    ps -axo pid,ppid,user,comm,%cpu,%mem,etime | {
      IFS= read -r header
      printf '%s\n' "$header"
      sort -nrk 5 | head -10
    }
    [ "$i" -lt 3 ] && sleep 1
  done
else
  echo "No supported process CPU sampling command found."
fi
