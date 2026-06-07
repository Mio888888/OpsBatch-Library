#!/usr/bin/env bash
set -euo pipefail

LIMIT="${PROCESS_LIMIT:-80}"

echo "信息：== processes running from temporary or user-writable paths =="
if command -v ps >/dev/null 2>&1; then
  if [ "$(uname -s)" = "Linux" ]; then
    ps -eo pid,ppid,user,etimes,comm,args 2>/dev/null | awk 'NR==1 || $0 ~ /(\/tmp\/|\/var\/tmp\/|\/dev\/shm\/|\/run\/user\/|\/Users\/Shared\/|\/private\/tmp\/)/' | head -n "$LIMIT"
  else
    ps auxww 2>/dev/null | awk 'NR==1 || $0 ~ /(\/tmp\/|\/var\/tmp\/|\/Users\/Shared\/|\/private\/tmp\/)/' | head -n "$LIMIT"
  fi
fi

echo
echo "信息：== deleted executable or library hints on Linux =="
if [ "$(uname -s)" = "Linux" ] && command -v lsof >/dev/null 2>&1; then
  lsof +L1 2>/dev/null | head -n "$LIMIT" || true
else
  echo "Deleted-open-file inspection 需要 Linux with lsof.（Deleted-open-file inspection requires Linux with lsof.）"
fi

echo
echo "信息：== high privilege long-running processes =="
if [ "$(uname -s)" = "Linux" ]; then
  ps -eo pid,user,etimes,comm,args 2>/dev/null | awk 'NR==1 || ($2 == "root" && $3 > 86400)' | head -n "$LIMIT"
else
  ps auxww 2>/dev/null | awk 'NR==1 || ($1 == "root")' | head -n "$LIMIT"
fi
