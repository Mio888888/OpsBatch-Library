#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
REMOVE_HOME="${REMOVE_HOME:-false}"
CONFIRM_DELETE_USER="${CONFIRM_DELETE_USER:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： user 未找到: $TARGET_USER（Refusing to run: user not found: $TARGET_USER）"
  exit 0
fi

echo "信息：== planned user deletion =="
id "$TARGET_USER" 2>/dev/null || true
echo "信息：REMOVE_HOME=$REMOVE_HOME"
echo
echo "信息：== current processes =="
ps -u "$TARGET_USER" -o pid,stat,etime,command 2>/dev/null | head -40 || true

if [ "$CONFIRM_DELETE_USER" != "DELETE_TARGET_USER" ]; then
  echo "仅试运行。 请设置 CONFIRM_DELETE_USER=DELETE_TARGET_USER 在确认后 backups, owned files, active processes and approval.（Dry-run only. Set CONFIRM_DELETE_USER=DELETE_TARGET_USER after confirming backups, owned files, active processes and approval.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if [ "$REMOVE_HOME" = "true" ]; then
    sudo userdel -r "$TARGET_USER"
  else
    sudo userdel "$TARGET_USER"
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if [ "$REMOVE_HOME" = "true" ]; then
    home="$(dscl . -read "/Users/$TARGET_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
    sudo dscl . -delete "/Users/$TARGET_USER"
    [ -n "$home" ] && [ -d "$home" ] && echo "信息：Home directory remains for manual review: $home"
  else
    sudo dscl . -delete "/Users/$TARGET_USER"
  fi
else
  echo "未找到受支持的 local user deletion tool found.（No supported local user deletion tool found.）"
fi
