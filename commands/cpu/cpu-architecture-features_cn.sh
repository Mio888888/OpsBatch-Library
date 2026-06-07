#!/usr/bin/env bash
set -euo pipefail

if command -v lscpu >/dev/null 2>&1; then
  lscpu | grep -E 'Architecture|Byte Order|CPU op-mode|Vendor ID|Model name|Flags|Virtualization' || true
elif [ "$(uname -s)" = "Darwin" ] && command -v sysctl >/dev/null 2>&1; then
  sysctl machdep.cpu.brand_string machdep.cpu.features machdep.cpu.leaf7_features hw.optional.arm64 hw.optional.x86_64 2>/dev/null || true
elif [ -r /proc/cpuinfo ]; then
  grep -m 1 -E '^(flags|Features|model name|Hardware|Processor)' /proc/cpuinfo
else
  echo "未找到受支持的 CPU 特性命令。"
fi
