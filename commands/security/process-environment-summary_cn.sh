#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-120}"
echo "信息：正在检查 PID=$pid 的环境变量。可用 PID=<pid> 覆盖；可用 PROCESS_LIMIT=<n> 限制行数。"
echo "信息：警告：环境变量可能包含令牌、密钥、密码、凭据或内部端点。"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r "/proc/$pid/environ" ]; then
    echo
    echo "信息：== /proc/$pid/environ =="
    tr '\0' '\n' < "/proc/$pid/environ" | sort | head -n "$limit"
  else
    echo "未找到进程 $pid，或 /proc/$pid/environ 不可读。你可能需要更高权限。"
  fi
elif command -v ps >/dev/null 2>&1; then
  echo
  echo "信息：== ps environment output =="
  ps eww -p "$pid" 2>/dev/null | head -n "$limit" || echo "信息：无法获取 PID 的环境变量 $pid 在当前平台上。"
else
  echo "未找到受支持的 process environment命令。"
fi
