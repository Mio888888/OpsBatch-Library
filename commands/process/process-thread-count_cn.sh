#!/usr/bin/env bash
set -euo pipefail

limit="${PROCESS_LIMIT:-20}"
echo "正在按线程数显示前 $limit 个进程。需要时可用 PROCESS_LIMIT=<n> 覆盖。"

if [ "$(uname -s)" = "Linux" ] && ps -eo pid,ppid,user,nlwp,stat,%cpu,%mem,comm --sort=-nlwp >/dev/null 2>&1; then
  ps -eo pid,ppid,user,nlwp,stat,%cpu,%mem,comm --sort=-nlwp | head -n "$((limit + 1))"
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v top >/dev/null 2>&1; then
    top -l 1 -n "$limit" -stats pid,th,command,cpu,mem,state,time -o th 2>/dev/null | awk 'BEGIN {show=0} /^PID[[:space:]]/ {show=1} show {print}'
  else
    echo "未找到受支持的 macOS 上的线程数统计命令."
  fi
else
  ps -eLf 2>/dev/null | awk 'NR>1 {count[$2]++; user[$2]=$3; cmd[$2]=$NF} END {for (pid in count) print pid, user[pid], count[pid], cmd[pid]}' | sort -nrk 3 | head -n "$limit"
fi
