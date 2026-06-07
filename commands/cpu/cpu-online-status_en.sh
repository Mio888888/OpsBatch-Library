#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== Online CPU list =="
  cat /sys/devices/system/cpu/online 2>/dev/null || true
  echo
  echo "== Offline CPU list =="
  cat /sys/devices/system/cpu/offline 2>/dev/null || true
  echo
  echo "== Per-CPU online flags =="
  for file in /sys/devices/system/cpu/cpu*/online; do
    [ -r "$file" ] || continue
    echo "$file=$(cat "$file")"
  done | head -80
elif [ "$(uname -s)" = "Darwin" ]; then
  sysctl hw.ncpu hw.activecpu hw.physicalcpu hw.logicalcpu 2>/dev/null || true
else
  echo "No supported CPU online-status command found."
fi
