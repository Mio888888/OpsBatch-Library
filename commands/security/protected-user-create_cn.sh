#!/usr/bin/env bash
set -euo pipefail

NEW_USER="${NEW_USER:-}"
NEW_USER_COMMENT="${NEW_USER_COMMENT:-OpsBatch managed user}"
NEW_USER_SHELL="${NEW_USER_SHELL:-/bin/bash}"
NEW_USER_HOME="${NEW_USER_HOME:-}"
CONFIRM_CREATE_USER="${CONFIRM_CREATE_USER:-}"

if [ -z "$NEW_USER" ]; then
  echo "拒绝执行： set NEW_USER explicitly."
  exit 0
fi

case "$NEW_USER" in
  *[!a-zA-Z0-9._-]*|'')
    echo "拒绝执行： NEW_USER 包含不支持的字符。"
    exit 0
    ;;
esac

echo "信息：== 计划创建本地用户 =="
echo "信息：NEW_USER=$NEW_USER"
echo "信息：NEW_USER_COMMENT=$NEW_USER_COMMENT"
echo "信息：NEW_USER_SHELL=$NEW_USER_SHELL"
echo "信息：NEW_USER_HOME=${NEW_USER_HOME:-default}"

if id "$NEW_USER" >/dev/null 2>&1; then
  echo "拒绝执行： 用户已存在: $NEW_USER"
  exit 0
fi

if [ "$CONFIRM_CREATE_USER" != "CREATE_LOCAL_USER" ]; then
  echo "仅试运行。 请设置 CONFIRM_CREATE_USER=CREATE_LOCAL_USER 在审核用户名、shell、主目录和密码初始化计划后。"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if [ -n "$NEW_USER_HOME" ]; then
    sudo useradd -m -d "$NEW_USER_HOME" -s "$NEW_USER_SHELL" -c "$NEW_USER_COMMENT" "$NEW_USER"
  else
    sudo useradd -m -s "$NEW_USER_SHELL" -c "$NEW_USER_COMMENT" "$NEW_USER"
  fi
  echo "用户已创建。请通过已批准的密钥流程设置初始密码或密钥。"
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  uid="${NEW_USER_UID:-}"
  if [ -z "$uid" ]; then
    uid="$(dscl . -list /Users UniqueID 2>/dev/null | awk '{print $2}' | sort -n | tail -1 | awk '{print $1 + 1}')"
  fi
  home="${NEW_USER_HOME:-/Users/$NEW_USER}"
  sudo dscl . -create "/Users/$NEW_USER"
  sudo dscl . -create "/Users/$NEW_USER" UserShell "$NEW_USER_SHELL"
  sudo dscl . -create "/Users/$NEW_USER" RealName "$NEW_USER_COMMENT"
  sudo dscl . -create "/Users/$NEW_USER" UniqueID "$uid"
  sudo dscl . -create "/Users/$NEW_USER" PrimaryGroupID "20"
  sudo dscl . -create "/Users/$NEW_USER" NFSHomeDirectory "$home"
  sudo createhomedir -c -u "$NEW_USER" >/dev/null 2>&1 || true
  echo "用户已创建。请通过已批准的密钥流程设置初始密码或密钥。"
else
  echo "未找到受支持的 本地用户创建工具。"
fi
