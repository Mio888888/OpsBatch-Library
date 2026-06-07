#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
CONFIRM_LOCK_USER="${CONFIRM_LOCK_USER:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： user 未找到: $TARGET_USER（Refusing to run: user not found: $TARGET_USER）"
  exit 0
fi

echo "信息：== planned account lock =="
id "$TARGET_USER" 2>/dev/null || true
ps -u "$TARGET_USER" -o pid,stat,etime,command 2>/dev/null | head -20 || true

if [ "$CONFIRM_LOCK_USER" != "LOCK_TARGET_USER" ]; then
  echo "仅试运行。 请设置 CONFIRM_LOCK_USER=LOCK_TARGET_USER 在确认后 active sessions, service accounts and rollback path.（Dry-run only. Set CONFIRM_LOCK_USER=LOCK_TARGET_USER after confirming active sessions, service accounts and rollback path.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  sudo passwd -l "$TARGET_USER"
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  sudo pwpolicy -u "$TARGET_USER" -setpolicy isDisabled=1
else
  echo "未找到受支持的 account lock tool found.（No supported account lock tool found.）"
fi
