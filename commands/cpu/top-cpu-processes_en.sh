#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,comm,%cpu,%mem,etime | {
    IFS= read -r header
    printf '%s\n' "$header"
    sort -nrk 5 | head -10
  }
elif ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu >/dev/null 2>&1; then
  ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu | head -11
else
  ps aux | sort -nrk 3 | head -10
fi
