#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
LINES="${LINES:-50}"

if [ -z "$TARGET_USER" ]; then
  echo "Refusing to run: set TARGET_USER explicitly."
  exit 0
fi

echo "== recent login records for $TARGET_USER =="
last -n "$LINES" "$TARGET_USER" 2>/dev/null || echo "No recent login records found or last is unavailable."

echo
echo "== failed login records for $TARGET_USER =="
lastb -n "$LINES" "$TARGET_USER" 2>/dev/null || echo "lastb unavailable or requires permission."

echo
echo "== current processes for $TARGET_USER =="
ps -u "$TARGET_USER" -o pid,stat,etime,command 2>/dev/null | head -n "$LINES" || true
