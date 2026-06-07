#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "Inspecting cgroup membership for PID=$pid. Override with PID=<pid> if needed."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/cgroup" ]; then
    echo "== /proc/$pid/cgroup =="
    cat "/proc/$pid/cgroup"
    echo
    echo "== container hints =="
    grep -E 'docker|kubepods|containerd|crio|libpod|lxc' "/proc/$pid/cgroup" || echo "No common container runtime keyword found in cgroup path."
  else
    echo "Process $pid not found or /proc/$pid/cgroup is not readable."
  fi
else
  echo "cgroup is Linux-specific; no cgroup information is available on $(uname -s)."
fi
