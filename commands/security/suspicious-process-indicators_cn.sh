#!/usr/bin/env bash
set -euo pipefail

LIMIT="${PROCESS_LIMIT:-80}"

echo "信息：== 从临时目录或用户可写路径运行的进程 =="
if command -v ps >/dev/null 2>&1; then
  if [ "$(uname -s)" = "Linux" ]; then
    ps -eo pid,ppid,user,etimes,comm,args 2>/dev/null | awk 'NR==1 || $0 ~ /(\/tmp\/|\/var\/tmp\/|\/dev\/shm\/|\/run\/user\/|\/Users\/Shared\/|\/private\/tmp\/)/' | head -n "$LIMIT"
  else
    ps auxww 2>/dev/null | awk 'NR==1 || $0 ~ /(\/tmp\/|\/var\/tmp\/|\/Users\/Shared\/|\/private\/tmp\/)/' | head -n "$LIMIT"
  fi
fi

echo
echo "信息：== Linux 上已删除可执行文件或库提示 =="
if [ "$(uname -s)" = "Linux" ] && command -v lsof >/dev/null 2>&1; then
  lsof +L1 2>/dev/null | head -n "$LIMIT" || true
else
  echo "已删除但仍打开的文件检查需要 Linux 和 lsof。"
fi

echo
echo "信息：== 高权限长时间运行进程 =="
if [ "$(uname -s)" = "Linux" ]; then
  ps -eo pid,user,etimes,comm,args 2>/dev/null | awk 'NR==1 || ($2 == "root" && $3 > 86400)' | head -n "$LIMIT"
else
  ps auxww 2>/dev/null | awk 'NR==1 || ($1 == "root")' | head -n "$LIMIT"
fi
