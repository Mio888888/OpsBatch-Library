#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-}"
if [ -n "$pid" ]; then
  echo "信息：正在检查 PID=$pid 附近的进程树。需要时可用 PID=<pid> 覆盖。"
else
  echo "正在检查系统进程树。pstree 可用时，请设置 PID=<pid> 聚焦到单个进程。"
fi

if command -v pstree >/dev/null 2>&1; then
  if [ -n "$pid" ]; then
    pstree -ap "$pid" 2>/dev/null || pstree "$pid" 2>/dev/null || echo "Process $pid 未找到 by pstree."
  else
    pstree -ap 2>/dev/null || pstree 2>/dev/null
  fi
elif [ -n "$pid" ]; then
  echo "未找到 pstree。正在通过 ps 显示匹配 PID 和直接子进程。"
  ps -eo pid,ppid,user,stat,etime,comm 2>/dev/null | awk -v p="$pid" 'NR==1 || $1==p || $2==p'
else
  echo "未找到 pstree。改为显示 PID/PPID 表以便手动检查进程树。"
  ps -eo pid,ppid,user,stat,etime,comm 2>/dev/null | head -80 || ps ax -o pid,ppid,user,stat,etime,comm | head -80
fi
