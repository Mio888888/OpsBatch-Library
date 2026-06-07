#!/usr/bin/env bash
set -euo pipefail

limit="${PROCESS_LIMIT:-30}"
echo "正在显示运行时间最长的前 $limit 个进程。需要时可用 PROCESS_LIMIT=<n> 覆盖。"

if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,lstart,etime,comm | head -n "$((limit + 1))"
elif ps -eo pid,ppid,user,lstart,etime,comm --sort=start_time >/dev/null 2>&1; then
  ps -eo pid,ppid,user,lstart,etime,comm --sort=start_time | head -n "$((limit + 1))"
else
  ps aux | awk 'NR==1 || NR<=31'
fi

echo
echo "信息：长时间运行的进程不一定异常；请结合预期服务生命周期和部署历史比较。"
