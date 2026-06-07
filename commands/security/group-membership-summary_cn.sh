#!/usr/bin/env bash
set -euo pipefail

TARGET_GROUP="${TARGET_GROUP:-}"

echo "信息：== groups summary =="
if [ -n "$TARGET_GROUP" ]; then
  if command -v getent >/dev/null 2>&1; then
    getent group "$TARGET_GROUP" 2>/dev/null || echo "Group 未找到: $TARGET_GROUP（Group not found: $TARGET_GROUP）"
  elif [ -r /etc/group ]; then
    awk -F: -v group="$TARGET_GROUP" '$1 == group {print}' /etc/group
  elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
    dscl . -read "/Groups/$TARGET_GROUP" 2>/dev/null || echo "Group 未找到: $TARGET_GROUP（Group not found: $TARGET_GROUP）"
  fi
else
  if [ -r /etc/group ]; then
    awk -F: '{printf "%-24s gid=%-6s members=%s\n", $1, $3, $4}' /etc/group | sort -k2,2n
  elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
    dscl . -list /Groups PrimaryGroupID 2>/dev/null | sort -k2,2n || true
  else
    echo "未找到受支持的 group source found.（No supported group source found.）"
  fi
fi
