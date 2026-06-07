#!/usr/bin/env bash
set -euo pipefail

if command -v vmstat >/dev/null 2>&1; then
  vmstat 1 5
  echo "提示： cs 表示上下文切换，in 表示中断，r 表示运行队列。"
elif [ "$(uname -s)" = "Linux" ] && [ -r /proc/stat ]; then
  grep -E '^(ctxt|processes|procs_running|procs_blocked)' /proc/stat
elif [ "$(uname -s)" = "Darwin" ] && command -v iostat >/dev/null 2>&1; then
  iostat -w 1 -c 5
  echo "macOS iostat 可辅助观察系统吞吐；详细调度指标通常需要更专业工具。"
else
  echo "未找到受支持的 调度器/上下文切换命令。"
fi
