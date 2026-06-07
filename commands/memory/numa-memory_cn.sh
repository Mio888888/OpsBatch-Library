#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v numactl >/dev/null 2>&1; then
    echo "信息：== numactl --hardware =="
    numactl --hardware
  else
    echo "信息：未安装 numactl；检查 /sys 节点内存文件。"
  fi

  echo
  echo "信息：== Node memory info =="
  if ls /sys/devices/system/node/node*/meminfo >/dev/null 2>&1; then
    for file in /sys/devices/system/node/node*/meminfo; do
      echo "信息：-- ${file%/meminfo} --"
      grep -E 'MemTotal|MemFree|MemUsed|FilePages|AnonPages|Slab|HugePages' "$file" || true
    done
  else
    echo "信息：未找到 NUMA 节点 meminfo 文件。"
  fi
else
  echo "信息：此命令中的 NUMA 内存分布检查依赖 Linux numactl 或 /sys 节点 meminfo。"
fi
