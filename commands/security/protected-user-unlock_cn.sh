#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
CONFIRM_UNLOCK_USER="${CONFIRM_UNLOCK_USER:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： user 未找到: $TARGET_USER（Refusing to run: user not found: $TARGET_USER）"
  exit 0
fi

echo "信息：== planned account unlock =="
id "$TARGET_USER" 2>/dev/null || true

if [ "$CONFIRM_UNLOCK_USER" != "UNLOCK_TARGET_USER" ]; then
  echo "仅试运行。 请设置 CONFIRM_UNLOCK_USER=UNLOCK_TARGET_USER 在确认后 approval and password/key state.（Dry-run only. Set CONFIRM_UNLOCK_USER=UNLOCK_TARGET_USER after confirming approval and password/key state.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  sudo passwd -u "$TARGET_USER"
  if command -v faillock >/dev/null 2>&1; then
    sudo faillock --user "$TARGET_USER" --reset 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  sudo pwpolicy -u "$TARGET_USER" -setpolicy isDisabled=0
else
  echo "未找到受支持的 account unlock tool found.（No supported account unlock tool found.）"
fi
