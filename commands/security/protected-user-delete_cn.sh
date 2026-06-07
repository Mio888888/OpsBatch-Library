#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
REMOVE_HOME="${REMOVE_HOME:-false}"
CONFIRM_DELETE_USER="${CONFIRM_DELETE_USER:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly."
  exit 0
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "拒绝执行： 用户未找到: $TARGET_USER"
  exit 0
fi

echo "信息：== 计划删除用户 =="
id "$TARGET_USER" 2>/dev/null || true
echo "信息：REMOVE_HOME=$REMOVE_HOME"
echo
echo "信息：== 当前进程 =="
ps -u "$TARGET_USER" -o pid,stat,etime,command 2>/dev/null | head -40 || true

if [ "$CONFIRM_DELETE_USER" != "DELETE_TARGET_USER" ]; then
  echo "仅试运行。请在确认备份、所属文件、活动进程和审批后设置 CONFIRM_DELETE_USER=DELETE_TARGET_USER。"
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
    [ -n "$home" ] && [ -d "$home" ] && echo "信息：家目录保留以供人工复核： $home"
  else
    sudo dscl . -delete "/Users/$TARGET_USER"
  fi
else
  echo "未找到受支持的 本地用户删除工具。"
fi
