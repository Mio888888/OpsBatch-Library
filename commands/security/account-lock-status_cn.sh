#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

echo "信息：== identity =="
id "$TARGET_USER" 2>/dev/null || { echo "User 未找到: $TARGET_USER（User not found: $TARGET_USER）"; exit 0; }

if [ "$(uname -s)" = "Linux" ]; then
  echo
  echo "信息：== passwd status =="
  passwd -S "$TARGET_USER" 2>/dev/null || sudo passwd -S "$TARGET_USER" 2>/dev/null || echo "无法读取 passwd status.（Cannot read passwd status.）"

  echo
  echo "信息：== shadow lock marker =="
  if command -v getent >/dev/null 2>&1; then
    sudo getent shadow "$TARGET_USER" 2>/dev/null | awk -F: '{print "shadow_password_prefix=" substr($2,1,3)}' || true
  else
    echo "getent is 不可用.（getent is not available.）"
  fi

  if command -v faillock >/dev/null 2>&1; then
    echo
    echo "信息：== faillock =="
    sudo faillock --user "$TARGET_USER" 2>/dev/null || faillock --user "$TARGET_USER" 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  pwpolicy -u "$TARGET_USER" getaccountpolicies 2>/dev/null || echo "无法读取 macOS account policy for $TARGET_USER.（Cannot read macOS account policy for $TARGET_USER.）"
else
  echo "未找到受支持的 account lock status source found.（No supported account lock status source found.）"
fi
