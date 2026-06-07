#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v taskset >/dev/null 2>&1; then
    echo "== Current shell affinity =="
    taskset -pc $$
    echo
    echo "== Top process affinity =="
    ps -eo pid,comm,%cpu --sort=-%cpu | head -11 | while read -r pid comm cpu; do
      if [ "$pid" = "PID" ]; then
        printf '%-8s %-24s %-8s %s\n' "PID" "COMMAND" "%CPU" "AFFINITY"
        continue
      fi
      affinity=$(taskset -pc "$pid" 2>/dev/null | sed 's/.*: //')
      printf '%-8s %-24s %-8s %s\n' "$pid" "$comm" "$cpu" "$affinity"
    done
  else
    echo "taskset not installed; cannot inspect Linux CPU affinity with this command."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "macOS does not provide a taskset-style built-in affinity inspection command."
  ps -axo pid,comm,%cpu | sort -nrk 3 | head -10
else
  echo "No supported CPU affinity command found."
fi
