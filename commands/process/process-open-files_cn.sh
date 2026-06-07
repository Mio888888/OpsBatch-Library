#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-80}"
echo "信息：正在检查 PID=$pid 打开的文件。可用 PID=<pid> 覆盖；可用 PROCESS_LIMIT=<n> 限制行数。"

if command -v lsof >/dev/null 2>&1; then
  echo "信息：== open regular files from lsof =="
  lsof -nP -p "$pid" 2>/dev/null | awk 'NR==1 || $5 == "REG" || $5 == "DIR"' | head -n "$limit" || echo "未找到进程 $pid，或 lsof 需要更多权限。"
elif [ "$(uname -s)" = "Linux" ] && [ -d "/proc/$pid/fd" ]; then
  echo "lsof 未找到. 正在显示 readable /proc/$pid/fd targets."
  for fd in /proc/"$pid"/fd/*; do
    [ -e "$fd" ] || continue
    target=$(readlink "$fd" 2>/dev/null || true)
    case "$target" in
      socket:*|pipe:*|anon_inode:*) continue ;;
    esac
    printf '%s -> %s\n' "$(basename "$fd")" "$target"
  done | head -n "$limit"
else
  echo "未找到受支持的 打开文件命令。 请安装 lsof，或在 Linux 上检查 /proc。"
fi
