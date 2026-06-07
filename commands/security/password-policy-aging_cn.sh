#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"

if [ "$(uname -s)" = "Linux" ]; then
  if [ -n "$TARGET_USER" ]; then
    echo "信息：== $TARGET_USER 的密码有效期 =="
    if command -v chage >/dev/null 2>&1; then
      sudo chage -l "$TARGET_USER" 2>/dev/null || chage -l "$TARGET_USER" 2>/dev/null || echo "无法读取 $TARGET_USER 的密码老化信息。"
    else
      echo "chage 不可用。"
    fi
  else
    echo "信息：== password policy files =="
    for file in /etc/login.defs /etc/security/faillock.conf /etc/pam.d/common-password /etc/pam.d/system-auth; do
      if [ -r "$file" ]; then
        echo "信息：-- $file --"
        grep -Ev '^[[:space:]]*(#|$)' "$file" 2>/dev/null | head -80 || true
      fi
    done
    echo
    echo "请设置 TARGET_USER，以便使用 chage 检查单个用户的密码有效期。"
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  pwpolicy getaccountpolicies 2>/dev/null || echo "无法读取 macOS 密码策略。"
else
  echo "未找到受支持的 密码策略来源。"
fi
