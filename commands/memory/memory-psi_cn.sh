#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r /proc/pressure/memory ]; then
    cat /proc/pressure/memory
    echo
    echo "Hint: avg10/avg60/avg300 表示最近窗口内因内存压力阻塞的时间比例，total 为累计微秒。"
  else
    echo "/proc/pressure/memory is 不可用; kernel may not enable PSI.（/proc/pressure/memory is not available; kernel may not enable PSI.）"
  fi
else
  echo "信息：Memory PSI is a Linux /proc pressure interface."
fi
