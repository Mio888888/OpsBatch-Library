#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
TARGET_SHELL="${TARGET_SHELL:-}"
CONFIRM_SHELL_CHANGE="${CONFIRM_SHELL_CHANGE:-}"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_SHELL" ]; then
  echo "拒绝执行： set TARGET_USER and TARGET_SHELL explicitly."
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： 用户未找到: $TARGET_USER"
  exit 0
fi

if [ -f /etc/shells ] && ! grep -qx "$TARGET_SHELL" /etc/shells; then
  echo "信息：警告：TARGET_SHELL 未列在 /etc/shells 中：$TARGET_SHELL"
fi

echo "信息：== 计划 shell 变更 =="
echo "信息：TARGET_USER=$TARGET_USER"
echo "信息：TARGET_SHELL=$TARGET_SHELL"
echo "信息：当前 passwd 条目:"
if command -v getent >/dev/null 2>&1; then
  getent passwd "$TARGET_USER" 2>/dev/null || true
elif [ -r /etc/passwd ]; then
  awk -F: -v user="$TARGET_USER" '$1 == user {print}' /etc/passwd
fi

if [ "$CONFIRM_SHELL_CHANGE" != "CHANGE_TARGET_SHELL" ]; then
  echo "仅试运行。 请设置 CONFIRM_SHELL_CHANGE=CHANGE_TARGET_SHELL 在确认后 登录/服务影响后。"
  exit 0
fi

if command -v chsh >/dev/null 2>&1; then
  sudo chsh -s "$TARGET_SHELL" "$TARGET_USER"
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  sudo dscl . -create "/Users/$TARGET_USER" UserShell "$TARGET_SHELL"
else
  echo "未找到受支持的 shell change tool。"
fi
