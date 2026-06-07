#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if [ -r /proc/pressure/memory ]; then
    cat /proc/pressure/memory
    echo
    echo "Hint: avg10/avg60/avg300 show the percentage of recent time stalled by memory pressure, and total is cumulative microseconds."
  else
    echo "/proc/pressure/memory is not available; kernel may not enable PSI."
  fi
else
  echo "Memory PSI is a Linux /proc pressure interface."
fi
