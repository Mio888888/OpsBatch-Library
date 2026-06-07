#!/usr/bin/env bash
set -euo pipefail

if command -v lscpu >/dev/null 2>&1; then
  lscpu
elif [ "$(uname -s)" = "Darwin" ] && command -v sysctl >/dev/null 2>&1; then
  sysctl -n machdep.cpu.brand_string 2>/dev/null || true
  sysctl hw.ncpu 2>/dev/null || true
  sysctl hw.physicalcpu 2>/dev/null || true
  sysctl hw.logicalcpu 2>/dev/null || true
  sysctl hw.optional.arm64 2>/dev/null || true
elif [ -f /proc/cpuinfo ]; then
  grep -E '^(model name|Hardware|Processor|cpu cores|siblings|processor)' /proc/cpuinfo | head -60
else
  echo "未找到受支持的 CPU information command found.（No supported CPU information command found.）"
fi
