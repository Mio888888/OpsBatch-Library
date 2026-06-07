#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-$(whoami 2>/dev/null || true)}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly.（Refusing to run: set TARGET_USER explicitly.）"
  exit 0
fi

echo "信息：== process summary for $TARGET_USER =="
ps -u "$TARGET_USER" -o pid,ppid,stat,%cpu,%mem,etime,command 2>/dev/null | head -n "${LINES:-80}" || echo "信息：Cannot list processes for $TARGET_USER."

echo
echo "信息：== top CPU/memory processes for $TARGET_USER =="
ps -u "$TARGET_USER" -o pid,%cpu,%mem,etime,command 2>/dev/null | sort -k2,2nr | head -n 20 || true
