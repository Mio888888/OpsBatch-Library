#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v numactl >/dev/null 2>&1; then
    echo "信息：== numactl --hardware =="
    numactl --hardware
  else
    echo "信息：numactl not installed; checking /sys node memory files."
  fi

  echo
  echo "信息：== Node memory info =="
  if ls /sys/devices/system/node/node*/meminfo >/dev/null 2>&1; then
    for file in /sys/devices/system/node/node*/meminfo; do
      echo "信息：-- ${file%/meminfo} --"
      grep -E 'MemTotal|MemFree|MemUsed|FilePages|AnonPages|Slab|HugePages' "$file" || true
    done
  else
    echo "信息：No NUMA node meminfo files found."
  fi
else
  echo "信息：NUMA memory distribution in this command relies on Linux numactl or /sys node meminfo."
fi
