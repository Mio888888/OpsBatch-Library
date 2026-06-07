#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
limit="${PROCESS_LIMIT:-120}"
echo "信息：正在检查 PID=$pid 的网络连接。可用 PID=<pid> 覆盖；可用 PROCESS_LIMIT=<n> 限制行数。"

if command -v lsof >/dev/null 2>&1; then
  echo "信息：== network sockets from lsof =="
  lsof -nP -a -p "$pid" -iTCP -iUDP 2>/dev/null | head -n "$limit" || echo "信息：未找到套接字，或 lsof 需要更多权限。"
elif [ "$(uname -s)" = "Linux" ] && command -v ss >/dev/null 2>&1; then
  echo "信息：== sockets with process info from ss =="
  ss -tunap 2>/dev/null | { head -1; grep -F "pid=$pid," || true; } | head -n "$limit"
elif command -v netstat >/dev/null 2>&1; then
  echo "信息：== 来自 netstat 的套接字（进程映射可能不可用） =="
  netstat -an 2>/dev/null | head -n "$limit"
else
  echo "未找到受支持的 进程网络命令。 请安装 lsof 或 iproute2。"
fi
