#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"
TARGET_URL="${TARGET_URL:-https://example.com}"

echo "== target =="
echo "TARGET_HOST=$TARGET_HOST"
echo "TARGET_URL=$TARGET_URL"

echo
echo "== ping =="
ping -c 4 "$TARGET_HOST" 2>/dev/null || echo "Ping failed or ICMP is blocked."

if command -v curl >/dev/null 2>&1; then
  echo
  echo "== HTTP(S) reachability =="
  curl -I --max-time 10 "$TARGET_URL" 2>/dev/null || echo "curl failed or target is not HTTP(S)."
fi
