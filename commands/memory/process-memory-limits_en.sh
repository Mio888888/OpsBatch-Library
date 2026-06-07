#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  pid="${PID:-1}"
  echo "Inspecting PID=$pid. Override with PID=<pid> if needed."

  echo
  echo "== current shell ulimit -a =="
  ulimit -a

  echo
  echo "== /proc/$pid/limits memory-related fields =="
  if [ -r "/proc/$pid/limits" ]; then
    grep -E 'Limit|Max address space|Max locked memory|Max resident set|Max stack size|Max data size' "/proc/$pid/limits" || true
  else
    echo "/proc/$pid/limits is not readable."
  fi
else
  echo "Process memory limits in this command rely on Linux /proc/<pid>/limits."
fi
