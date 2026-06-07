#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ] || [ "$(uname -s)" = "Darwin" ]; then
  if command -v ipcs >/dev/null 2>&1; then
    echo "信息：== ipcs -m =="
    ipcs -m
  else
    echo "信息：ipcs command not installed."
  fi

  if [ "$(uname -s)" = "Linux" ] && [ -r /proc/meminfo ]; then
    echo
    echo "信息：== Shared memory fields in /proc/meminfo =="
    grep -E '^(Shmem|ShmemHugePages|ShmemPmdMapped):' /proc/meminfo || true
  fi
else
  echo "未找到受支持的 shared memory inspection command found.（No supported shared memory inspection command found.）"
fi
