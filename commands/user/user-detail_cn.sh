#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-$(whoami 2>/dev/null || true)}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

echo "信息：== identity =="
id "$TARGET_USER" 2>/dev/null || { echo "User 未找到: $TARGET_USER（User not found: $TARGET_USER）"; exit 0; }

echo
echo "信息：== passwd entry =="
if command -v getent >/dev/null 2>&1; then
  getent passwd "$TARGET_USER" 2>/dev/null || true
elif [ -r /etc/passwd ]; then
  awk -F: -v user="$TARGET_USER" '$1 == user {print}' /etc/passwd
fi

echo
echo "信息：== groups =="
groups "$TARGET_USER" 2>/dev/null || id -Gn "$TARGET_USER" 2>/dev/null || true

echo
echo "信息：== home and shell hints =="
if [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
  dscl . -read "/Users/$TARGET_USER" NFSHomeDirectory UserShell UniqueID PrimaryGroupID 2>/dev/null || true
elif command -v getent >/dev/null 2>&1; then
  getent passwd "$TARGET_USER" | awk -F: '{print "home=" $6 "\nshell=" $7}'
fi
