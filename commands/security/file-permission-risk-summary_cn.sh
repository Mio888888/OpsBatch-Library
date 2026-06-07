#!/usr/bin/env bash
set -euo pipefail

SCAN_ROOT="${SCAN_ROOT:-/}"
MAX_DEPTH="${MAX_DEPTH:-3}"
LIMIT="${LIMIT:-100}"

echo "正在扫描 metadata under SCAN_ROOT=$SCAN_ROOT MAX_DEPTH=$MAX_DEPTH. This is read-only but may be expensive on large trees.（Scanning metadata under SCAN_ROOT=$SCAN_ROOT MAX_DEPTH=$MAX_DEPTH. This is read-only but may be expensive on large trees.）"

echo
echo "信息：== world-writable directories without sticky bit =="
find "$SCAN_ROOT" -xdev -maxdepth "$MAX_DEPTH" -type d -perm -0002 ! -perm -1000 -print 2>/dev/null | head -n "$LIMIT"

echo
echo "信息：== setuid/setgid files =="
find "$SCAN_ROOT" -xdev -maxdepth "$MAX_DEPTH" \( -perm -4000 -o -perm -2000 \) -type f -ls 2>/dev/null | head -n "$LIMIT"

echo
echo "信息：== writable sensitive config hints =="
for path in /etc/passwd /etc/group /etc/shadow /etc/sudoers /etc/ssh/sshd_config; do
  [ -e "$path" ] && ls -l "$path" 2>/dev/null || true
done
