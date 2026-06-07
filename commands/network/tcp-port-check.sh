#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-127.0.0.1}"
TARGET_PORT="${TARGET_PORT:-80}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-5}"

echo "Checking TCP connectivity to ${TARGET_HOST}:${TARGET_PORT} with timeout ${TIMEOUT_SECONDS}s"

if command -v nc >/dev/null 2>&1; then
  nc -vz -w "$TIMEOUT_SECONDS" "$TARGET_HOST" "$TARGET_PORT"
elif command -v bash >/dev/null 2>&1; then
  if command -v timeout >/dev/null 2>&1; then
    timeout "$TIMEOUT_SECONDS" bash -c 'cat < /dev/tcp/"$1"/"$2"' _ "$TARGET_HOST" "$TARGET_PORT" \
      && echo "TCP port is reachable." \
      || echo "TCP port is not reachable or bash /dev/tcp is unavailable."
  else
    bash -c 'cat < /dev/tcp/"$1"/"$2"' _ "$TARGET_HOST" "$TARGET_PORT" \
      && echo "TCP port is reachable." \
      || echo "TCP port is not reachable or bash /dev/tcp is unavailable."
  fi
else
  echo "No TCP probing tool found. Install nc or use scripts/python/check-tcp-port.py."
fi
