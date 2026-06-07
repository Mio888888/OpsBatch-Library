#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ] || [ "$(uname -s)" = "Darwin" ]; then
  if command -v ipcs >/dev/null 2>&1; then
    echo "信息：== ipcs -m =="
    ipcs -m
  else
    echo "信息：未安装 ipcs 命令。"
  fi

  if [ "$(uname -s)" = "Linux" ] && [ -r /proc/meminfo ]; then
    echo
    echo "信息：== /proc/meminfo 中的共享内存字段 =="
    grep -E '^(Shmem|ShmemHugePages|ShmemPmdMapped):' /proc/meminfo || true
  fi
else
  echo "未找到受支持的 共享内存检查命令。"
fi
