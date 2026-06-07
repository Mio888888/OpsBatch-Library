#!/usr/bin/env bash
set -euo pipefail

TARGET_SERVICE="${TARGET_SERVICE:-}"
CONFIRM_STOP_SERVICE="${CONFIRM_STOP_SERVICE:-}"

if [ -z "$TARGET_SERVICE" ]; then
  echo "拒绝执行：请显式设置 TARGET_SERVICE。"
  exit 0
fi

echo "信息：== 计划停止服务 =="
printf 'target_service=%s\n' "$TARGET_SERVICE"
if [ "$(uname -s)" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
  systemctl status "$TARGET_SERVICE" --no-pager 2>/dev/null | head -60 || true
elif [ "$(uname -s)" = "Darwin" ] && command -v launchctl >/dev/null 2>&1; then
  launchctl list 2>/dev/null | grep -F "$TARGET_SERVICE" || true
else
  echo "未找到受支持的 服务管理器状态命令。"
fi

if [ "$CONFIRM_STOP_SERVICE" != "STOP_TARGET_SERVICE" ]; then
  echo "仅试运行。 请设置 CONFIRM_STOP_SERVICE=STOP_TARGET_SERVICE 在确认后 业务影响、依赖和重启计划后。"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
  sudo systemctl stop "$TARGET_SERVICE"
elif [ "$(uname -s)" = "Darwin" ] && command -v launchctl >/dev/null 2>&1; then
  echo "信息：请在审核服务域/路径后使用 launchctl bootout；此通用模板不会自动停止 macOS 服务。"
else
  echo "未找到受支持的 服务管理器。"
fi
