#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v sar >/dev/null 2>&1; then
    echo "信息：== sar -r 最近内存趋势 =="
    sar -r 1 3

    echo
    echo "信息：== sar -S 最近交换分区趋势 =="
    sar -S 1 3 2>/dev/null || echo "此 sysstat 版本中 sar -S 不可用。"
  else
    echo "信息：未安装 sar 命令；请安装 sysstat 以查看历史内存趋势。"
    if command -v free >/dev/null 2>&1; then
      echo
      echo "信息：当前内存快照回退信息:"
      free -h
    fi
  fi
else
  echo "信息：此命令中的 sar 内存趋势检查仅适用于 Linux/sysstat。"
fi
