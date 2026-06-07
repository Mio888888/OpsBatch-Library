#!/usr/bin/env bash
set -euo pipefail

echo "信息：Shell resource limits:"
ulimit -a
if [ -r /proc/self/limits ]; then
  echo "信息：Process limits from /proc/self/limits:"
  cat /proc/self/limits
fi
