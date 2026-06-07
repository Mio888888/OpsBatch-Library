#!/usr/bin/env bash
set -euo pipefail

pid="${PID:-1}"
echo "Inspecting namespaces for PID=$pid. Override with PID=<pid> if needed."

if [ "$(uname -s)" = "Linux" ]; then
  if [ -d "/proc/$pid/ns" ]; then
    echo "== /proc/$pid/ns =="
    for ns in /proc/"$pid"/ns/*; do
      [ -e "$ns" ] || continue
      printf '%s -> ' "$(basename "$ns")"
      readlink "$ns" 2>/dev/null || echo "not readable"
    done | sort
    echo
    echo "Compare namespace inode values across processes to identify shared or isolated namespaces."
  else
    echo "Process $pid not found or /proc/$pid/ns is not readable."
  fi
else
  echo "Linux namespaces are not available on $(uname -s)."
fi
