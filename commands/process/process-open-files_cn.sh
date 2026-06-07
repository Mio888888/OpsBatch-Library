#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-80}"
echo "信息：Inspecting open files for PID=$pid. Override with PID=<pid>; limit rows with PROCESS_LIMIT=<n>."

if command -v lsof >/dev/null 2>&1; then
  echo "信息：== open regular files from lsof =="
  lsof -nP -p "$pid" 2>/dev/null | awk 'NR==1 || $5 == "REG" || $5 == "DIR"' | head -n "$limit" || echo "Process $pid 未找到 or lsof needs more permission.（Process $pid not found or lsof needs more permission.）"
elif [ "$(uname -s)" = "Linux" ] && [ -d "/proc/$pid/fd" ]; then
  echo "lsof 未找到. 正在显示 readable /proc/$pid/fd targets.（lsof not found. Showing readable /proc/$pid/fd targets.）"
  for fd in /proc/"$pid"/fd/*; do
    [ -e "$fd" ] || continue
    target=$(readlink "$fd" 2>/dev/null || true)
    case "$target" in
      socket:*|pipe:*|anon_inode:*) continue ;;
    esac
    printf '%s -> %s\n' "$(basename "$fd")" "$target"
  done | head -n "$limit"
else
  echo "未找到受支持的 open-file command found. Install lsof or inspect /proc on Linux.（No supported open-file command found. Install lsof or inspect /proc on Linux.）"
fi
