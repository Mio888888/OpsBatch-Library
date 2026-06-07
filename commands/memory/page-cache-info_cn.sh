#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r /proc/meminfo ]; then
    echo "信息：== Page cache 相关字段 =="
    grep -E '^(Cached|SwapCached|Buffers|Dirty|Writeback|WritebackTmp|Active\(file\)|Inactive\(file\)|Mapped|Shmem|SReclaimable):' /proc/meminfo || true
  else
    echo "/proc/meminfo 不可用。"
  fi

  echo
  echo "信息：== 缓存相关 vm 设置（只读） =="
  for file in /proc/sys/vm/dirty_background_ratio /proc/sys/vm/dirty_ratio /proc/sys/vm/vfs_cache_pressure; do
    [ -r "$file" ] && echo "信息：$file=$(cat "$file")"
  done
else
  echo "信息：此命令中的 Page Cache 详情依赖 Linux /proc/meminfo 和 /proc/sys/vm。"
fi
