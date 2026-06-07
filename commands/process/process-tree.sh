#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-}"
if [ -n "$pid" ]; then
  echo "Inspecting process tree around PID=$pid. Override with PID=<pid> if needed."
else
  echo "Inspecting system process tree. Set PID=<pid> to focus on one process when pstree is available."
fi

if command -v pstree >/dev/null 2>&1; then
  if [ -n "$pid" ]; then
    pstree -ap "$pid" 2>/dev/null || pstree "$pid" 2>/dev/null || echo "Process $pid not found by pstree."
  else
    pstree -ap 2>/dev/null || pstree 2>/dev/null
  fi
elif [ -n "$pid" ]; then
  echo "pstree not found. Showing matching PID and direct children from ps."
  ps -eo pid,ppid,user,stat,etime,comm 2>/dev/null | awk -v p="$pid" 'NR==1 || $1==p || $2==p'
else
  echo "pstree not found. Showing PID/PPID table for manual tree inspection."
  ps -eo pid,ppid,user,stat,etime,comm 2>/dev/null | head -80 || ps ax -o pid,ppid,user,stat,etime,comm | head -80
fi
