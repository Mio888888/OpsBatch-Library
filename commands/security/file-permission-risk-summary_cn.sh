#!/usr/bin/env bash
set -euo pipefail

SCAN_ROOT="${SCAN_ROOT:-/}"
MAX_DEPTH="${MAX_DEPTH:-3}"
LIMIT="${LIMIT:-100}"

echo "正在扫描以下位置的元数据： SCAN_ROOT=$SCAN_ROOT MAX_DEPTH=$MAX_DEPTH. 这是只读操作，但在大型目录树上可能开销较大。"

echo
echo "信息：== 未设置 sticky bit 的全局可写目录 =="
find "$SCAN_ROOT" -xdev -maxdepth "$MAX_DEPTH" -type d -perm -0002 ! -perm -1000 -print 2>/dev/null | head -n "$LIMIT"

echo
echo "信息：== setuid/setgid files =="
find "$SCAN_ROOT" -xdev -maxdepth "$MAX_DEPTH" \( -perm -4000 -o -perm -2000 \) -type f -ls 2>/dev/null | head -n "$LIMIT"

echo
echo "信息：== 敏感配置可写风险提示 =="
for path in /etc/passwd /etc/group /etc/shadow /etc/sudoers /etc/ssh/sshd_config; do
  [ -e "$path" ] && ls -l "$path" 2>/dev/null || true
done
