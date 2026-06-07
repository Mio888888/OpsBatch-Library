#!/usr/bin/env bash
set -euo pipefail

if command -v journalctl >/dev/null 2>&1; then
  journalctl -n 100 --no-pager
elif [ -f /var/log/system.log ]; then
  tail -n 100 /var/log/system.log
else
  echo "未找到受支持的 系统日志来源。"
fi
