#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ] || [ "$(uname -s)" = "Darwin" ]; then
  if command -v ipcs >/dev/null 2>&1; then
    echo "== ipcs -m =="
    ipcs -m
  else
    echo "ipcs command not installed."
  fi

  if [ "$(uname -s)" = "Linux" ] && [ -r /proc/meminfo ]; then
    echo
    echo "== Shared memory fields in /proc/meminfo =="
    grep -E '^(Shmem|ShmemHugePages|ShmemPmdMapped):' /proc/meminfo || true
  fi
else
  echo "No supported shared memory inspection command found."
fi
