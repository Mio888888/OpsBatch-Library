#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "信息：Inspecting namespaces for PID=$pid. Override with PID=<pid> if needed."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -d "/proc/$pid/ns" ]; then
    echo "信息：== /proc/$pid/ns =="
    for ns in /proc/"$pid"/ns/*; do
      [ -e "$ns" ] || continue
      printf '%s -> ' "$(basename "$ns")"
      readlink "$ns" 2>/dev/null || echo "信息：not readable"
    done | sort
    echo
    echo "信息：Compare namespace inode values across processes to identify shared or isolated namespaces."
  else
    echo "Process $pid 未找到 or /proc/$pid/ns is not readable.（Process $pid not found or /proc/$pid/ns is not readable.）"
  fi
else
  echo "Linux namespaces are 不可用 on $(uname -s).（Linux namespaces are not available on $(uname -s).）"
fi
