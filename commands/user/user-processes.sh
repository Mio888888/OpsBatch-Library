#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-$(whoami 2>/dev/null || true)}"

if [ -z "$TARGET_USER" ]; then
  echo "Refusing to run: set TARGET_USER explicitly."
  exit 0
fi

echo "== process summary for $TARGET_USER =="
ps -u "$TARGET_USER" -o pid,ppid,stat,%cpu,%mem,etime,command 2>/dev/null | head -n "${LINES:-80}" || echo "Cannot list processes for $TARGET_USER."

echo
echo "== top CPU/memory processes for $TARGET_USER =="
ps -u "$TARGET_USER" -o pid,%cpu,%mem,etime,command 2>/dev/null | sort -k2,2nr | head -n 20 || true
