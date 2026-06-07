#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r /proc/meminfo ]; then
    echo "== Page cache related fields =="
    grep -E '^(Cached|SwapCached|Buffers|Dirty|Writeback|WritebackTmp|Active\(file\)|Inactive\(file\)|Mapped|Shmem|SReclaimable):' /proc/meminfo || true
  else
    echo "/proc/meminfo is not available."
  fi

  echo
  echo "== Cache-related vm settings (read-only) =="
  for file in /proc/sys/vm/dirty_background_ratio /proc/sys/vm/dirty_ratio /proc/sys/vm/vfs_cache_pressure; do
    [ -r "$file" ] && echo "$file=$(cat "$file")"
  done
else
  echo "Page Cache details in this command rely on Linux /proc/meminfo and /proc/sys/vm."
fi
