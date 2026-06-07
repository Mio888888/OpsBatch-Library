#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-ssh}"
SINCE="${SINCE:-2 hours ago}"
LINES="${LINES:-120}"

echo "信息：== 服务日志：$SERVICE_NAME，自 $SINCE 起 =="
if [ "$(uname -s)" = "Linux" ] && command -v journalctl >/dev/null 2>&1; then
  journalctl -u "$SERVICE_NAME" --since "$SINCE" -n "$LINES" --no-pager 2>/dev/null || echo "信息：未找到 journal 条目或服务权限不足： $SERVICE_NAME"
elif [ "$(uname -s)" = "Darwin" ] && command -v log >/dev/null 2>&1; then
  log show --last 2h --style compact --predicate "process == \"$SERVICE_NAME\"" 2>/dev/null | tail -n "$LINES" || true
else
  echo "未找到受支持的 服务日志命令。请将 SERVICE_NAME 设置为目标服务/进程名称。"
fi
