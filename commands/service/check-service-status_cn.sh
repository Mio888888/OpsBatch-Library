#!/usr/bin/env bash
set -euo pipefail
# 中文说明：此脚本与英文版本保持相同执行逻辑，仅保留中文本地化说明。

SERVICE=${SERVICE:-ssh}
if command -v systemctl >/dev/null 2>&1; then
  systemctl status "$SERVICE" --no-pager
elif command -v service >/dev/null 2>&1; then
  service "$SERVICE" status
else
  pgrep -fl "$SERVICE" || true
fi
