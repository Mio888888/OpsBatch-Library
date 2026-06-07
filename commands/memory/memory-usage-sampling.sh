#!/usr/bin/env bash
set -euo pipefail

samples="${SAMPLES:-5}"
interval="${INTERVAL:-2}"
echo "Sampling memory usage: SAMPLES=$samples INTERVAL=${interval}s. Override with SAMPLES=<n> INTERVAL=<seconds>."

if [ "$(uname -s)" = "Linux" ]; then
  i=1
  while [ "$i" -le "$samples" ]; do
    echo "== sample $i $(date '+%Y-%m-%d %H:%M:%S') =="
    if command -v free >/dev/null 2>&1; then
      free -h
    elif [ -r /proc/meminfo ]; then
      grep -E '^(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree):' /proc/meminfo || true
    else
      echo "No supported Linux memory source found."
    fi
    [ "$i" -lt "$samples" ] && sleep "$interval"
    i=$((i + 1))
  done
elif [ "$(uname -s)" = "Darwin" ]; then
  i=1
  while [ "$i" -le "$samples" ]; do
    echo "== sample $i $(date '+%Y-%m-%d %H:%M:%S') =="
    if command -v vm_stat >/dev/null 2>&1; then
      vm_stat
    else
      echo "vm_stat not available."
    fi
    [ "$i" -lt "$samples" ] && sleep "$interval"
    i=$((i + 1))
  done
else
  echo "No supported memory sampling command found."
fi
