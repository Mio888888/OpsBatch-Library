#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pid="${PID:-1}"
  echo "信息：正在检查 PID=$pid。需要时可用 PID=<pid> 覆盖。"

  echo
  echo "信息：== 当前 shell ulimit -a =="
  ulimit -a

  echo
  echo "信息：== /proc/$pid/limits memory-related fields =="
  if [ -r "/proc/$pid/limits" ]; then
    grep -E 'Limit|Max address space|Max locked memory|Max resident set|Max stack size|Max data size' "/proc/$pid/limits" || true
  else
    echo "信息：/proc/$pid/limits 不可读。"
  fi
else
  echo "信息：此命令中的进程内存限制检查依赖 Linux /proc/<pid>/limits。"
fi
