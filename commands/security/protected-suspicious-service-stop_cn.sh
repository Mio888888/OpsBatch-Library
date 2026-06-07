#!/usr/bin/env bash
set -euo pipefail

TARGET_SERVICE="${TARGET_SERVICE:-}"
CONFIRM_STOP_SERVICE="${CONFIRM_STOP_SERVICE:-}"

if [ -z "$TARGET_SERVICE" ]; then
  echo "拒绝执行： set TARGET_SERVICE explicitly.（Refusing to run: set TARGET_SERVICE explicitly.）"
  exit 0
fi

echo "信息：== planned service stop =="
printf 'target_service=%s\n' "$TARGET_SERVICE"
if [ "$(uname -s)" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
  systemctl status "$TARGET_SERVICE" --no-pager 2>/dev/null | head -60 || true
elif [ "$(uname -s)" = "Darwin" ] && command -v launchctl >/dev/null 2>&1; then
  launchctl list 2>/dev/null | grep -F "$TARGET_SERVICE" || true
else
  echo "未找到受支持的 service manager status command found.（No supported service manager status command found.）"
fi

if [ "$CONFIRM_STOP_SERVICE" != "STOP_TARGET_SERVICE" ]; then
  echo "仅试运行。 请设置 CONFIRM_STOP_SERVICE=STOP_TARGET_SERVICE 在确认后 business impact, dependencies and restart plan.（Dry-run only. Set CONFIRM_STOP_SERVICE=STOP_TARGET_SERVICE after confirming business impact, dependencies and restart plan.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
  sudo systemctl stop "$TARGET_SERVICE"
elif [ "$(uname -s)" = "Darwin" ] && command -v launchctl >/dev/null 2>&1; then
  echo "信息：Use launchctl bootout with a reviewed service domain/path; this generic template does not stop macOS services automatically."
else
  echo "未找到受支持的 service manager found.（No supported service manager found.）"
fi
