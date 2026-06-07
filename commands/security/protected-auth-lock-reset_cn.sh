#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
CONFIRM_RESET_AUTH_LOCK="${CONFIRM_RESET_AUTH_LOCK:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly."
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： 用户未找到: $TARGET_USER"
  exit 0
fi

echo "信息：== 计划重置认证锁定 =="
id "$TARGET_USER" 2>/dev/null || true
if command -v faillock >/dev/null 2>&1; then
  sudo faillock --user "$TARGET_USER" 2>/dev/null || faillock --user "$TARGET_USER" 2>/dev/null || true
fi

if [ "$CONFIRM_RESET_AUTH_LOCK" != "RESET_TARGET_AUTH_LOCK" ]; then
  echo "仅试运行。 请设置 CONFIRM_RESET_AUTH_LOCK=RESET_TARGET_AUTH_LOCK 在确认后 锁定原因与审批后。"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ] && command -v faillock >/dev/null 2>&1; then
  sudo faillock --user "$TARGET_USER" --reset
else
  echo "未找到受支持的 authentication lock reset tool。"
fi
