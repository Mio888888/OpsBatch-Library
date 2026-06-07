#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
CONFIRM_EXPIRE_PASSWORD="${CONFIRM_EXPIRE_PASSWORD:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： user 未找到: $TARGET_USER（Refusing to run: user not found: $TARGET_USER）"
  exit 0
fi

echo "信息：== planned password expiration =="
id "$TARGET_USER" 2>/dev/null || true

if [ "$CONFIRM_EXPIRE_PASSWORD" != "EXPIRE_TARGET_PASSWORD" ]; then
  echo "仅试运行。 请设置 CONFIRM_EXPIRE_PASSWORD=EXPIRE_TARGET_PASSWORD 在确认后 user notification and access path.（Dry-run only. Set CONFIRM_EXPIRE_PASSWORD=EXPIRE_TARGET_PASSWORD after confirming user notification and access path.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v chage >/dev/null 2>&1; then
    sudo chage -d 0 "$TARGET_USER"
  else
    sudo passwd -e "$TARGET_USER"
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  sudo pwpolicy -u "$TARGET_USER" -setpolicy "newPasswordRequired=1"
else
  echo "未找到受支持的 password expiration tool found.（No supported password expiration tool found.）"
fi
