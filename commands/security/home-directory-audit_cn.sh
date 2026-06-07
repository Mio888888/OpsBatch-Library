#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"

if [ -r /etc/passwd ]; then
  if [ -n "$TARGET_USER" ]; then
    awk -F: -v user="$TARGET_USER" '$1 == user {print}' /etc/passwd
  else
    awk -F: '$6 != "" {print}' /etc/passwd
  fi | while IFS=: read -r user _ uid gid gecos home shell; do
    [ -z "$user" ] && continue
    printf '%s uid=%s home=%s shell=%s\n' "$user" "$uid" "$home" "$shell"
    if [ -d "$home" ]; then
      ls -ld "$home" 2>/dev/null || true
      owner="$(ls -ldn "$home" 2>/dev/null | awk '{print $3":"$4}')"
      if [ "$owner" != "$uid:$gid" ]; then
        echo "信息：  警告：主目录所有者数字 uid/gid 为 $owner, 预期 $uid:$gid"
      fi
    else
      echo "信息：  警告：主目录缺失或不是目录"
    fi
    echo
  done
elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  users="${TARGET_USER:-$(dscl . -list /Users 2>/dev/null)}"
  for user in $users; do
    home="$(dscl . -read "/Users/$user" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
    shell="$(dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}')"
    printf '%s home=%s shell=%s\n' "$user" "$home" "$shell"
    [ -n "$home" ] && ls -ld "$home" 2>/dev/null || echo "信息：  警告：主目录缺失或不可读"
    echo
  done
else
  echo "未找到受支持的 用户主目录来源。"
fi
