#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
TARGET_SHELL="${TARGET_SHELL:-}"
CONFIRM_SHELL_CHANGE="${CONFIRM_SHELL_CHANGE:-}"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_SHELL" ]; then
  echo "拒绝执行： set TARGET_USER and TARGET_SHELL explicitly.（Refusing to run: set TARGET_USER and TARGET_SHELL explicitly.）"
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： user 未找到: $TARGET_USER（Refusing to run: user not found: $TARGET_USER）"
  exit 0
fi

if [ -f /etc/shells ] && ! grep -qx "$TARGET_SHELL" /etc/shells; then
  echo "信息：Warning: TARGET_SHELL is not listed in /etc/shells: $TARGET_SHELL"
fi

echo "信息：== planned shell change =="
echo "信息：TARGET_USER=$TARGET_USER"
echo "信息：TARGET_SHELL=$TARGET_SHELL"
echo "信息：Current passwd entry:"
if command -v getent >/dev/null 2>&1; then
  getent passwd "$TARGET_USER" 2>/dev/null || true
elif [ -r /etc/passwd ]; then
  awk -F: -v user="$TARGET_USER" '$1 == user {print}' /etc/passwd
fi

if [ "$CONFIRM_SHELL_CHANGE" != "CHANGE_TARGET_SHELL" ]; then
  echo "仅试运行。 请设置 CONFIRM_SHELL_CHANGE=CHANGE_TARGET_SHELL 在确认后 login/service impact.（Dry-run only. Set CONFIRM_SHELL_CHANGE=CHANGE_TARGET_SHELL after confirming login/service impact.）"
  exit 0
fi

if command -v chsh >/dev/null 2>&1; then
  sudo chsh -s "$TARGET_SHELL" "$TARGET_USER"
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  sudo dscl . -create "/Users/$TARGET_USER" UserShell "$TARGET_SHELL"
else
  echo "未找到受支持的 shell change tool found.（No supported shell change tool found.）"
fi
