#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-127.0.0.1}"
TARGET_PORT="${TARGET_PORT:-80}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-5}"

echo "信息：正在检查到 ${TARGET_HOST}:${TARGET_PORT} 的 TCP 连通性，超时 ${TIMEOUT_SECONDS}s"

if command -v nc >/dev/null 2>&1; then
  nc -vz -w "$TIMEOUT_SECONDS" "$TARGET_HOST" "$TARGET_PORT"
elif command -v bash >/dev/null 2>&1; then
  if command -v timeout >/dev/null 2>&1; then
    timeout "$TIMEOUT_SECONDS" bash -c 'cat < /dev/tcp/"$1"/"$2"' _ "$TARGET_HOST" "$TARGET_PORT" \
      && echo "信息：TCP 端口可达。" \
      || echo "信息：TCP 端口不可达，或 bash /dev/tcp 不可用。"
  else
    bash -c 'cat < /dev/tcp/"$1"/"$2"' _ "$TARGET_HOST" "$TARGET_PORT" \
      && echo "信息：TCP 端口可达。" \
      || echo "信息：TCP 端口不可达，或 bash /dev/tcp 不可用。"
  fi
else
  echo "信息：未找到 TCP 探测工具。请安装 nc。"
fi
