#!/usr/bin/env bash
set -euo pipefail

echo "== Load average =="
uptime

cpu_count=""
if command -v nproc >/dev/null 2>&1; then
  cpu_count=$(nproc 2>/dev/null || true)
elif command -v sysctl >/dev/null 2>&1; then
  cpu_count=$(sysctl -n hw.logicalcpu 2>/dev/null || true)
elif command -v getconf >/dev/null 2>&1; then
  cpu_count=$(getconf _NPROCESSORS_ONLN 2>/dev/null || true)
fi

if [ -n "$cpu_count" ]; then
  echo "Logical CPU count: $cpu_count"
  echo "Hint: a load average that stays above the logical CPU count usually indicates CPU pressure or uninterruptible wait pressure."
fi

if command -v vmstat >/dev/null 2>&1; then
  echo
  echo "== vmstat 1 5 =="
  vmstat 1 5
elif [ "$(uname -s)" = "Darwin" ] && command -v top >/dev/null 2>&1; then
  echo
  echo "== top snapshot =="
  top -l 1 | head -20
else
  echo "vmstat/top not available; only load average was shown."
fi
