#!/usr/bin/env bash
set -euo pipefail
# 中文说明：此脚本与英文版本保持相同执行逻辑，仅保留中文本地化说明。

if command -v ss >/dev/null 2>&1; then
  ss -tuln
elif command -v netstat >/dev/null 2>&1; then
  netstat -tuln
else
  lsof -nP -iTCP -sTCP:LISTEN
fi
