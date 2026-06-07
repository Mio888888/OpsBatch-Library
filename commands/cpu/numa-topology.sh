#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v numactl >/dev/null 2>&1; then
    numactl --hardware
  elif command -v lscpu >/dev/null 2>&1; then
    lscpu | grep -E 'NUMA|Socket|Core\(s\)|Thread\(s\)|CPU\(s\)' || true
  elif ls /sys/devices/system/node/node* >/dev/null 2>&1; then
    for node in /sys/devices/system/node/node*; do
      echo "== ${node##*/} =="
      cat "$node/cpulist" 2>/dev/null || true
    done
  else
    echo "No NUMA topology source found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS does not expose Linux-style NUMA topology for common deployments."
  sysctl hw.physicalcpu hw.logicalcpu 2>/dev/null || true
else
  echo "No supported NUMA command found."
fi
