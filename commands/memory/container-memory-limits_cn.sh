#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== cgroup v2 memory limit =="
  if [ -r /sys/fs/cgroup/memory.max ]; then
    echo "信息：memory.max=$(cat /sys/fs/cgroup/memory.max)"
    [ -r /sys/fs/cgroup/memory.current ] && echo "信息：memory.current=$(cat /sys/fs/cgroup/memory.current)"
    [ -r /sys/fs/cgroup/memory.high ] && echo "信息：memory.high=$(cat /sys/fs/cgroup/memory.high)"
    [ -r /sys/fs/cgroup/memory.swap.max ] && echo "信息：memory.swap.max=$(cat /sys/fs/cgroup/memory.swap.max)"
  else
    echo "cgroup v2 memory files 未找到 at /sys/fs/cgroup."
  fi

  echo
  echo "信息：== cgroup v1 memory limit =="
  found=0
  for base in /sys/fs/cgroup/memory /sys/fs/cgroup; do
    [ -r "$base/memory.limit_in_bytes" ] || continue
    found=1
    echo "信息：$base/memory.limit_in_bytes=$(cat "$base/memory.limit_in_bytes")"
    [ -r "$base/memory.usage_in_bytes" ] && echo "信息：$base/memory.usage_in_bytes=$(cat "$base/memory.usage_in_bytes")"
    [ -r "$base/memory.memsw.limit_in_bytes" ] && echo "信息：$base/memory.memsw.limit_in_bytes=$(cat "$base/memory.memsw.limit_in_bytes")"
  done
  [ "$found" -eq 1 ] || echo "未找到 cgroup v1 内存限制文件。"
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS 不使用 Linux cgroup 内存限制。改为显示主机内存摘要。"
  sysctl hw.memsize 2>/dev/null || true
  command -v vm_stat >/dev/null 2>&1 && vm_stat
else
  echo "未找到受支持的 cgroup 内存命令。"
fi
