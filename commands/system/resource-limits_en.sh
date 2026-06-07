#!/usr/bin/env bash
set -euo pipefail

echo "Shell resource limits:"
ulimit -a
if [ -r /proc/self/limits ]; then
  echo "Process limits from /proc/self/limits:"
  cat /proc/self/limits
fi
