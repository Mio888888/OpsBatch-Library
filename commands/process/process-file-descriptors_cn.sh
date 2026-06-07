#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-80}"
echo "信息：正在检查 PID=$pid 的文件描述符。可用 PID=<pid> 覆盖；可用 PROCESS_LIMIT=<n> 限制行数。"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -d "/proc/$pid/fd" ]; then
    echo "信息：== fd count =="
    find "/proc/$pid/fd" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l | awk '{print $1}'
    echo
    echo "信息：== fd targets =="
    for fd in /proc/"$pid"/fd/*; do
      [ -e "$fd" ] || continue
      printf '%s -> ' "$(basename "$fd")"
      readlink "$fd" 2>/dev/null || echo "信息：不可读"
    done | head -n "$limit"
  else
    echo "Process $pid 未找到 or /proc/$pid/fd is 不可读."
  fi
elif command -v lsof >/dev/null 2>&1; then
  echo "信息：== fd list from lsof =="
  lsof -p "$pid" 2>/dev/null | head -n "$limit" || echo "未找到进程 $pid，或 lsof 需要更多权限。"
else
  echo "未找到受支持的 文件描述符命令。 请在 macOS 上安装 lsof。"
fi
