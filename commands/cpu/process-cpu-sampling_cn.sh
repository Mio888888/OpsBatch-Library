#!/usr/bin/env bash
set -euo pipefail

if command -v pidstat >/dev/null 2>&1; then
  pidstat -u 1 3
elif [ "$(uname -s)" = "Linux" ]; then
  echo "信息：未安装 pidstat；显示三次按 CPU 排序的 ps 快照。"
  for i in 1 2 3; do
    echo "信息：== 快照 $i =="
    if ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu >/dev/null 2>&1; then
      ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu | head -11
    else
      ps aux | sort -nrk 3 | head -10
    fi
    [ "$i" -lt 3 ] && sleep 1
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "正在显示 3 次按 CPU 排序的 macOS ps 快照。"
  for i in 1 2 3; do
    echo "信息：== 快照 $i =="
    ps -axo pid,ppid,user,comm,%cpu,%mem,etime | {
      IFS= read -r header
      printf '%s\n' "$header"
      sort -nrk 5 | head -10
    }
    [ "$i" -lt 3 ] && sleep 1
  done
else
  echo "未找到受支持的 进程 CPU 采样命令。"
fi
