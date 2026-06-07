#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== cgroup v2 CPU 限制 =="
  if [ -r /sys/fs/cgroup/cpu.max ]; then
    cat /sys/fs/cgroup/cpu.max
    echo "信息：格式：<quota> <period>；max 表示不限制。"
  else
    echo "未找到 cgroup v2 cpu.max。"
  fi

  echo
  echo "信息：== cgroup v1 CPU 限制 =="
  if [ -r /sys/fs/cgroup/cpu/cpu.cfs_quota_us ] || [ -r /sys/fs/cgroup/cpu,cpuacct/cpu.cfs_quota_us ]; then
    for base in /sys/fs/cgroup/cpu /sys/fs/cgroup/cpu,cpuacct; do
      [ -r "$base/cpu.cfs_quota_us" ] || continue
      echo "信息：$base/cpu.cfs_quota_us=$(cat "$base/cpu.cfs_quota_us")"
      echo "信息：$base/cpu.cfs_period_us=$(cat "$base/cpu.cfs_period_us" 2>/dev/null || true)"
    done
  else
    echo "未找到 cgroup v1 CPU quota 文件。"
  fi

  echo
  echo "信息：== cpuset =="
  for file in /sys/fs/cgroup/cpuset.cpus /sys/fs/cgroup/cpuset/cpuset.cpus /sys/fs/cgroup/cpuset.cpus.effective; do
    [ -r "$file" ] && echo "信息：$file=$(cat "$file")"
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：macOS 不使用 Linux cgroup CPU 限制。"
  sysctl hw.ncpu hw.physicalcpu hw.logicalcpu 2>/dev/null || true
else
  echo "未找到受支持的 cgroup CPU命令。"
fi
