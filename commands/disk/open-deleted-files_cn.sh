#!/usr/bin/env bash
set -euo pipefail

if command -v lsof >/dev/null 2>&1; then
  echo "信息：== 仍被打开的已删除文件 =="
  sudo lsof +L1 2>/dev/null || lsof +L1 2>/dev/null || true
elif [ "$(uname -s)" = "Linux" ]; then
  echo "信息：未安装 lsof；回退扫描 /proc 文件描述符。"
  find /proc/*/fd -lname '* (deleted)' -print 2>/dev/null | head -100
else
  echo "信息：此平台需要 lsof。"
fi
