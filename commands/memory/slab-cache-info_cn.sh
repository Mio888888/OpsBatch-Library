#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v slabtop >/dev/null 2>&1; then
    echo "信息：== slabtop -o =="
    slabtop -o | head -30
  elif [ -r /proc/slabinfo ]; then
    echo "信息：未安装 slabtop；显示 /proc/slabinfo 前几行。"
    head -30 /proc/slabinfo
  else
    echo "信息：未找到可读的 Slab 缓存来源。"
  fi

  if [ -r /proc/meminfo ]; then
    echo
    echo "信息：== Slab fields in /proc/meminfo =="
    grep -E '^(Slab|SReclaimable|SUnreclaim):' /proc/meminfo || true
  fi
else
  echo "信息：此命令中的 Slab 缓存检查依赖 Linux /proc/slabinfo 或 slabtop。"
fi
