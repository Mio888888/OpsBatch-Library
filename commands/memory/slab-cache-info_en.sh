#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v slabtop >/dev/null 2>&1; then
    echo "== slabtop -o =="
    slabtop -o | head -30
  elif [ -r /proc/slabinfo ]; then
    echo "slabtop not installed; showing top lines from /proc/slabinfo."
    head -30 /proc/slabinfo
  else
    echo "No readable Slab cache source found."
  fi

  if [ -r /proc/meminfo ]; then
    echo
    echo "== Slab fields in /proc/meminfo =="
    grep -E '^(Slab|SReclaimable|SUnreclaim):' /proc/meminfo || true
  fi
else
  echo "Slab cache inspection in this command relies on Linux /proc/slabinfo or slabtop."
fi
