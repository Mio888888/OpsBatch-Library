#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,comm,%mem,rss,vsz,etime | {
    IFS= read -r header
    printf '%s\n' "$header"
    sort -nrk 5 | head -10
  }
elif ps -eo pid,ppid,user,comm,%mem,rss,vsz,etime --sort=-%mem >/dev/null 2>&1; then
  ps -eo pid,ppid,user,comm,%mem,rss,vsz,etime --sort=-%mem | head -11
else
  ps aux | sort -nrk 4 | head -10
fi
