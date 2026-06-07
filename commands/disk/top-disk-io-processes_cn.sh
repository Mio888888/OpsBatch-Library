#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v iotop >/dev/null 2>&1; then
    sudo iotop -b -n 3 -o 2>/dev/null || iotop -b -n 3 -o 2>/dev/null || true
  elif command -v pidstat >/dev/null 2>&1; then
    pidstat -d 1 3
  else
    echo "信息：未安装 iotop 和 pidstat。请安装 iotop 或 sysstat 获取逐进程 I/O 详情。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v fs_usage >/dev/null 2>&1; then
    echo "fs_usage 通常需要 sudo；采样 5 秒。"
    sudo fs_usage -w -f filesys 2>/dev/null | head -80 || true
  else
    echo "fs_usage 不可用。"
  fi
else
  echo "未找到受支持的 逐进程磁盘 I/O命令。"
fi
