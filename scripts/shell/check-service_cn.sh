#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-${SERVICE:-ssh}}"

echo "服务: ${SERVICE}"

if command -v systemctl >/dev/null 2>&1; then
  systemctl is-active "${SERVICE}" || true
  systemctl status "${SERVICE}" --no-pager || true
elif command -v service >/dev/null 2>&1; then
  service "${SERVICE}" status || true
else
  pgrep -fl "${SERVICE}" || {
    echo "未找到匹配进程: ${SERVICE}."
    exit 0
  }
fi
