#!/usr/bin/env bash
set -euo pipefail

echo "信息：== 平均负载 =="
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
  echo "信息：逻辑 CPU 数: $cpu_count"
  echo "提示： load average 持续高于逻辑 CPU 数通常表示 CPU 或不可中断等待存在压力。"
fi

if command -v vmstat >/dev/null 2>&1; then
  echo
  echo "信息：== vmstat 1 5 =="
  vmstat 1 5
elif [ "$(uname -s)" = "Darwin" ] && command -v top >/dev/null 2>&1; then
  echo
  echo "信息：== top 快照 =="
  top -l 1 | head -20
else
  echo "vmstat/top 不可用；仅显示平均负载。"
fi
