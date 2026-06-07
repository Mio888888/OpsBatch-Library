#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== overcommit sysctls =="
  for file in /proc/sys/vm/overcommit_memory /proc/sys/vm/overcommit_ratio /proc/sys/vm/overcommit_kbytes; do
    [ -r "$file" ] && echo "$file=$(cat "$file")"
  done

  if [ -r /proc/meminfo ]; then
    echo
    echo "== Commitment fields =="
    grep -E '^(CommitLimit|Committed_AS|MemTotal|SwapTotal):' /proc/meminfo || true
  fi

  echo
  echo "Mode hint: 0=heuristic, 1=always overcommit, 2=strict limit."
else
  echo "Overcommit settings in this command rely on Linux /proc/sys/vm and /proc/meminfo."
fi
