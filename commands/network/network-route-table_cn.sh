#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "信息：== default route =="
    ip route show default || true

    echo
    echo "信息：== route table =="
    ip route show table main
  elif command -v route >/dev/null 2>&1; then
    route -n
  elif command -v netstat >/dev/null 2>&1; then
    netstat -rn
  else
    echo "信息：未找到路由检查命令。"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "信息：== default route =="
  route -n get default 2>/dev/null || true

  echo
  echo "信息：== route table =="
  netstat -rn
else
  echo "未找到受支持的 路由检查命令。"
fi
