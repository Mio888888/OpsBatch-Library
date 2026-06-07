#!/usr/bin/env bash
set -euo pipefail
# 中文说明：此脚本与英文版本保持相同执行逻辑，仅保留中文本地化说明。

if [ "$(uname -s)" = "Darwin" ]; then
  ps -axo pid,ppid,user,comm,%cpu,%mem,etime | {
    IFS= read -r header
    printf '%s\n' "$header"
    sort -nrk 5 | head -10
  }
elif ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu >/dev/null 2>&1; then
  ps -eo pid,ppid,user,comm,%cpu,%mem,etime --sort=-%cpu | head -11
else
  ps aux | sort -nrk 3 | head -10
fi
