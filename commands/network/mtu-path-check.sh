#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-example.com}"
PACKET_SIZE="${PACKET_SIZE:-1472}"

echo "== target =="
echo "TARGET_HOST=$TARGET_HOST"
echo "PACKET_SIZE=$PACKET_SIZE"

if [ "$(uname -s)" = "Linux" ]; then
  echo
  echo "== ping with do-not-fragment =="
  ping -c 4 -M do -s "$PACKET_SIZE" "$TARGET_HOST" 2>/dev/null || echo "Path MTU probe failed, ICMP is blocked, or packet size is too large."

  if command -v tracepath >/dev/null 2>&1; then
    echo
    echo "== tracepath MTU hints =="
    tracepath "$TARGET_HOST" 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo
  echo "== ping with do-not-fragment =="
  ping -c 4 -D -s "$PACKET_SIZE" "$TARGET_HOST" 2>/dev/null || echo "Path MTU probe failed, ICMP is blocked, or packet size is too large."
else
  echo "No supported MTU probe command found."
fi
