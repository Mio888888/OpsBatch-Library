#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"
MAX_HOPS="${MAX_HOPS:-20}"

echo "Tracing path to $TARGET_HOST with max hops $MAX_HOPS"

if command -v traceroute >/dev/null 2>&1; then
  traceroute -m "$MAX_HOPS" "$TARGET_HOST"
elif command -v tracepath >/dev/null 2>&1; then
  tracepath -m "$MAX_HOPS" "$TARGET_HOST"
elif command -v ping >/dev/null 2>&1; then
  echo "traceroute/tracepath not found; showing ping latency instead."
  ping -c 4 "$TARGET_HOST"
else
  echo "No traceroute, tracepath, or ping command found."
fi
