#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly."
  exit 0
fi

echo "信息：== identity =="
id "$TARGET_USER" 2>/dev/null || { echo "未找到用户： $TARGET_USER"; exit 0; }

if [ "$(uname -s)" = "Linux" ]; then
  echo
  echo "信息：== passwd 状态 =="
  passwd -S "$TARGET_USER" 2>/dev/null || sudo passwd -S "$TARGET_USER" 2>/dev/null || echo "无法读取 passwd 状态。"

  echo
  echo "信息：== shadow lock marker =="
  if command -v getent >/dev/null 2>&1; then
    sudo getent shadow "$TARGET_USER" 2>/dev/null | awk -F: '{print "shadow_password_prefix=" substr($2,1,3)}' || true
  else
    echo "getent 不可用。"
  fi

  if command -v faillock >/dev/null 2>&1; then
    echo
    echo "信息：== faillock =="
    sudo faillock --user "$TARGET_USER" 2>/dev/null || faillock --user "$TARGET_USER" 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ] && command -v pwpolicy >/dev/null 2>&1; then
  pwpolicy -u "$TARGET_USER" getaccountpolicies 2>/dev/null || echo "无法读取 $TARGET_USER 的 macOS 账号策略。"
else
  echo "未找到受支持的 账号锁定状态来源。"
fi
