#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
TARGET_GROUP="${TARGET_GROUP:-}"
GROUP_ACTION="${GROUP_ACTION:-add}"
CONFIRM_GROUP_CHANGE="${CONFIRM_GROUP_CHANGE:-}"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_GROUP" ]; then
  echo "拒绝执行： set TARGET_USER and TARGET_GROUP explicitly."
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： 用户未找到: $TARGET_USER"
  exit 0
fi

case "$GROUP_ACTION" in
  add|remove) ;;
  *) echo "拒绝执行： GROUP_ACTION 必须为 add 或 remove。"; exit 0 ;;
esac

echo "信息：== 计划组成员变更 =="
echo "信息：TARGET_USER=$TARGET_USER"
echo "信息：TARGET_GROUP=$TARGET_GROUP"
echo "信息：GROUP_ACTION=$GROUP_ACTION"
echo "信息：当前组: $(id -Gn "$TARGET_USER" 2>/dev/null || true)"

if [ "$CONFIRM_GROUP_CHANGE" != "CHANGE_GROUP_MEMBERSHIP" ]; then
  echo "仅试运行。 请设置 CONFIRM_GROUP_CHANGE=CHANGE_GROUP_MEMBERSHIP 在确认后 访问影响与审批后。"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if [ "$GROUP_ACTION" = "add" ]; then
    sudo usermod -aG "$TARGET_GROUP" "$TARGET_USER"
  else
    if command -v gpasswd >/dev/null 2>&1; then
      sudo gpasswd -d "$TARGET_USER" "$TARGET_GROUP"
    else
      echo "信息：在此 Linux 系统上，从组中移除用户需要 gpasswd。"
    fi
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v dseditgroup >/dev/null 2>&1; then
  if [ "$GROUP_ACTION" = "add" ]; then
    sudo dseditgroup -o edit -a "$TARGET_USER" -t user "$TARGET_GROUP"
  else
    sudo dseditgroup -o edit -d "$TARGET_USER" -t user "$TARGET_GROUP"
  fi
else
  echo "未找到受支持的 group membership tool。"
fi
