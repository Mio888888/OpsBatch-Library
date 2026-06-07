#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== cgroup v2 memory limit =="
  if [ -r /sys/fs/cgroup/memory.max ]; then
    echo "memory.max=$(cat /sys/fs/cgroup/memory.max)"
    [ -r /sys/fs/cgroup/memory.current ] && echo "memory.current=$(cat /sys/fs/cgroup/memory.current)"
    [ -r /sys/fs/cgroup/memory.high ] && echo "memory.high=$(cat /sys/fs/cgroup/memory.high)"
    [ -r /sys/fs/cgroup/memory.swap.max ] && echo "memory.swap.max=$(cat /sys/fs/cgroup/memory.swap.max)"
  else
    echo "cgroup v2 memory files not found at /sys/fs/cgroup."
  fi

  echo
  echo "== cgroup v1 memory limit =="
  found=0
  for base in /sys/fs/cgroup/memory /sys/fs/cgroup; do
    [ -r "$base/memory.limit_in_bytes" ] || continue
    found=1
    echo "$base/memory.limit_in_bytes=$(cat "$base/memory.limit_in_bytes")"
    [ -r "$base/memory.usage_in_bytes" ] && echo "$base/memory.usage_in_bytes=$(cat "$base/memory.usage_in_bytes")"
    [ -r "$base/memory.memsw.limit_in_bytes" ] && echo "$base/memory.memsw.limit_in_bytes=$(cat "$base/memory.memsw.limit_in_bytes")"
  done
  [ "$found" -eq 1 ] || echo "cgroup v1 memory limit files not found."
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS does not use Linux cgroup memory limits. Showing host memory summary instead."
  sysctl hw.memsize 2>/dev/null || true
  command -v vm_stat >/dev/null 2>&1 && vm_stat
else
  echo "No supported cgroup memory command found."
fi
