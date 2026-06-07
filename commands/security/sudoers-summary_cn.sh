#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"

echo "信息：== sudo availability =="
command -v sudo >/dev/null 2>&1 && sudo -V 2>/dev/null | head -5 || echo "sudo command 未找到 or not readable.（sudo command not found or not readable.）"

echo
echo "信息：== sudo-capable groups from local group database =="
if [ -r /etc/group ]; then
  grep -E '^(sudo|wheel|admin):' /etc/group 2>/dev/null || true
fi

echo
echo "信息：== sudoers files =="
for path in /etc/sudoers /etc/sudoers.d; do
  if [ -e "$path" ]; then
    ls -ld "$path" 2>/dev/null || true
  fi
done

if [ -n "$TARGET_USER" ]; then
  echo
  echo "信息：== sudo privileges for $TARGET_USER =="
  sudo -l -U "$TARGET_USER" 2>/dev/null || echo "Cannot list sudo privileges for $TARGET_USER; 可能需要权限.（Cannot list sudo privileges for $TARGET_USER; permission may be required.）"
else
  echo
  echo "请设置 TARGET_USER to run sudo -l -U for one user.（Set TARGET_USER to run sudo -l -U for one user.）"
fi
