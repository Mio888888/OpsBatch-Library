#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== cgroup v2 CPU limit =="
  if [ -r /sys/fs/cgroup/cpu.max ]; then
    cat /sys/fs/cgroup/cpu.max
    echo "Format: <quota> <period>; max means unlimited."
  else
    echo "cgroup v2 cpu.max not found."
  fi

  echo
  echo "== cgroup v1 CPU limit =="
  if [ -r /sys/fs/cgroup/cpu/cpu.cfs_quota_us ] || [ -r /sys/fs/cgroup/cpu,cpuacct/cpu.cfs_quota_us ]; then
    for base in /sys/fs/cgroup/cpu /sys/fs/cgroup/cpu,cpuacct; do
      [ -r "$base/cpu.cfs_quota_us" ] || continue
      echo "$base/cpu.cfs_quota_us=$(cat "$base/cpu.cfs_quota_us")"
      echo "$base/cpu.cfs_period_us=$(cat "$base/cpu.cfs_period_us" 2>/dev/null || true)"
    done
  else
    echo "cgroup v1 CPU quota files not found."
  fi

  echo
  echo "== cpuset =="
  for file in /sys/fs/cgroup/cpuset.cpus /sys/fs/cgroup/cpuset/cpuset.cpus /sys/fs/cgroup/cpuset.cpus.effective; do
    [ -r "$file" ] && echo "$file=$(cat "$file")"
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS does not use Linux cgroup CPU limits."
  sysctl hw.ncpu hw.physicalcpu hw.logicalcpu 2>/dev/null || true
else
  echo "No supported cgroup CPU command found."
fi
