#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
TARGET_GROUP="${TARGET_GROUP:-}"
GROUP_ACTION="${GROUP_ACTION:-add}"
CONFIRM_GROUP_CHANGE="${CONFIRM_GROUP_CHANGE:-}"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_GROUP" ]; then
  echo "拒绝执行： set TARGET_USER and TARGET_GROUP explicitly.（Refusing to run: set TARGET_USER and TARGET_GROUP explicitly.）"
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： user 未找到: $TARGET_USER（Refusing to run: user not found: $TARGET_USER）"
  exit 0
fi

case "$GROUP_ACTION" in
  add|remove) ;;
  *) echo "拒绝执行： GROUP_ACTION must be add or remove.（Refusing to run: GROUP_ACTION must be add or remove.）"; exit 0 ;;
esac

echo "信息：== planned group membership change =="
echo "信息：TARGET_USER=$TARGET_USER"
echo "信息：TARGET_GROUP=$TARGET_GROUP"
echo "信息：GROUP_ACTION=$GROUP_ACTION"
echo "信息：Current groups: $(id -Gn "$TARGET_USER" 2>/dev/null || true)"

if [ "$CONFIRM_GROUP_CHANGE" != "CHANGE_GROUP_MEMBERSHIP" ]; then
  echo "仅试运行。 请设置 CONFIRM_GROUP_CHANGE=CHANGE_GROUP_MEMBERSHIP 在确认后 access impact and approval.（Dry-run only. Set CONFIRM_GROUP_CHANGE=CHANGE_GROUP_MEMBERSHIP after confirming access impact and approval.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if [ "$GROUP_ACTION" = "add" ]; then
    sudo usermod -aG "$TARGET_GROUP" "$TARGET_USER"
  else
    if command -v gpasswd >/dev/null 2>&1; then
      sudo gpasswd -d "$TARGET_USER" "$TARGET_GROUP"
    else
      echo "信息：gpasswd is required to remove a user from a group on this Linux system."
    fi
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v dseditgroup >/dev/null 2>&1; then
  if [ "$GROUP_ACTION" = "add" ]; then
    sudo dseditgroup -o edit -a "$TARGET_USER" -t user "$TARGET_GROUP"
  else
    sudo dseditgroup -o edit -d "$TARGET_USER" -t user "$TARGET_GROUP"
  fi
else
  echo "未找到受支持的 group membership tool found.（No supported group membership tool found.）"
fi
