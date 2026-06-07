#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pid="${PID:-1}"
  echo "信息：正在检查 PID=$pid。需要时可用 PID=<pid> 覆盖。"

  if command -v pmap >/dev/null 2>&1; then
    pmap -x "$pid"
  elif [ -r "/proc/$pid/maps" ]; then
    echo "信息：未安装 pmap；显示 /proc/$pid/maps 前 50 行。"
    head -50 "/proc/$pid/maps"
  else
    echo "信息：未找到 PID $pid 的可读内存映射。"
  fi
else
  echo "信息：此命令中的进程内存映射检查依赖 Linux /proc 或 pmap 输出。"
fi
