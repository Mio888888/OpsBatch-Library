#!/usr/bin/env bash
set -euo pipefail

if command -v vmstat >/dev/null 2>&1; then
  vmstat 1 5
  echo "Hint: cs means context switches, in means interrupts, and r means the run queue."
elif [ "$(uname -s)" = "Linux" ] && [ -r /proc/stat ]; then
  grep -E '^(ctxt|processes|procs_running|procs_blocked)' /proc/stat
elif [ "$(uname -s)" = "Darwin" ] && command -v iostat >/dev/null 2>&1; then
  iostat -w 1 -c 5
  echo "Notice: see the command metadata for details."
else
  echo "No supported scheduler/context-switch command found."
fi
