#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"
MAX_HOPS="${MAX_HOPS:-20}"

echo "信息：Tracing path to $TARGET_HOST with max hops $MAX_HOPS"

if command -v traceroute >/dev/null 2>&1; then
  traceroute -m "$MAX_HOPS" "$TARGET_HOST"
elif command -v tracepath >/dev/null 2>&1; then
  tracepath -m "$MAX_HOPS" "$TARGET_HOST"
elif command -v ping >/dev/null 2>&1; then
  echo "traceroute/tracepath 未找到; showing ping latency instead.（traceroute/tracepath not found; showing ping latency instead.）"
  ping -c 4 "$TARGET_HOST"
else
  echo "信息：No traceroute, tracepath, or ping command found."
fi
