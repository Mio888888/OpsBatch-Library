#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== free -h =="
  if command -v free >/dev/null 2>&1; then
    free -h
  else
    echo "free not installed; showing key /proc/meminfo fields."
  fi

  if [ -r /proc/meminfo ]; then
    echo
    echo "== /proc/meminfo key fields =="
    grep -E '^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SReclaimable|Shmem|SwapTotal|SwapFree):' /proc/meminfo || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "== vm_stat =="
  if command -v vm_stat >/dev/null 2>&1; then
    vm_stat
  else
    echo "vm_stat not available."
  fi

  echo
  echo "== memory size =="
  sysctl hw.memsize 2>/dev/null || true
else
  echo "No supported memory summary command found."
fi
