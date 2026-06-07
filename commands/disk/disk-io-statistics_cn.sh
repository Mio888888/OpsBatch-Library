#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v iostat >/dev/null 2>&1; then
    iostat -xz 1 3
  else
    echo "信息：iostat not installed. Install sysstat to collect per-device I/O statistics."
    echo
    echo "信息：== /proc/diskstats snapshot =="
    cat /proc/diskstats 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v iostat >/dev/null 2>&1; then
    iostat -d -w 1 -c 3
  else
    echo "iostat 不可用.（iostat not available.）"
  fi
else
  echo "未找到受支持的 disk I/O statistics command found.（No supported disk I/O statistics command found.）"
fi
