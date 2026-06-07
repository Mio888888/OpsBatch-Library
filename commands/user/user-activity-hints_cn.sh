#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
LINES="${LINES:-50}"

if [ -z "$TARGET_USER" ]; then
  echo "拒绝执行： set TARGET_USER explicitly."
  exit 0
fi

echo "信息：== recent login records for $TARGET_USER =="
last -n "$LINES" "$TARGET_USER" 2>/dev/null || echo "信息：未找到最近登录记录，或 last 不可用。"

echo
echo "信息：== $TARGET_USER 的失败登录记录 =="
lastb -n "$LINES" "$TARGET_USER" 2>/dev/null || echo "lastb 不可用或需要权限。"

echo
echo "信息：== $TARGET_USER 的当前进程 =="
ps -u "$TARGET_USER" -o pid,stat,etime,command 2>/dev/null | head -n "$LINES" || true
