#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"
TARGET_URL="${TARGET_URL:-https://example.com}"

echo "信息：== 目标 =="
echo "信息：TARGET_HOST=$TARGET_HOST"
echo "信息：TARGET_URL=$TARGET_URL"

echo
echo "信息：== ping =="
ping -c 4 "$TARGET_HOST" 2>/dev/null || echo "信息：Ping 失败或 ICMP 被阻止。"

if command -v curl >/dev/null 2>&1; then
  echo
  echo "信息：== HTTP(S) reachability =="
  curl -I --max-time 10 "$TARGET_URL" 2>/dev/null || echo "信息：curl 失败或目标不是 HTTP(S)。"
fi
