#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
CONFIRM_RESET_AUTH_LOCK="${CONFIRM_RESET_AUTH_LOCK:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： user 未找到: $TARGET_USER（Refusing to run: user not found: $TARGET_USER）"
  exit 0
fi

echo "信息：== planned auth lock reset =="
id "$TARGET_USER" 2>/dev/null || true
if command -v faillock >/dev/null 2>&1; then
  sudo faillock --user "$TARGET_USER" 2>/dev/null || faillock --user "$TARGET_USER" 2>/dev/null || true
fi

if [ "$CONFIRM_RESET_AUTH_LOCK" != "RESET_TARGET_AUTH_LOCK" ]; then
  echo "仅试运行。 请设置 CONFIRM_RESET_AUTH_LOCK=RESET_TARGET_AUTH_LOCK 在确认后 the lockout cause and approval.（Dry-run only. Set CONFIRM_RESET_AUTH_LOCK=RESET_TARGET_AUTH_LOCK after confirming the lockout cause and approval.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ] && command -v faillock >/dev/null 2>&1; then
  sudo faillock --user "$TARGET_USER" --reset
else
  echo "未找到受支持的 authentication lock reset tool found.（No supported authentication lock reset tool found.）"
fi
