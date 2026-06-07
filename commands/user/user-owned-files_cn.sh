#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${TARGET_USER:-}"
TARGET_DIR="${TARGET_DIR:-}"
MAX_DEPTH="${MAX_DEPTH:-4}"
LINES="${LINES:-100}"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_DIR" ]; then
  echo "拒绝执行： set TARGET_USER and TARGET_DIR explicitly, for example TARGET_USER=app TARGET_DIR=/var/www."
  exit 0
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "信息：TARGET_DIR 不是目录: $TARGET_DIR"
  exit 0
fi

echo "信息：== $TARGET_DIR 下 $TARGET_USER 拥有的文件（最大深度 $MAX_DEPTH） =="
find "$TARGET_DIR" -xdev -maxdepth "$MAX_DEPTH" -user "$TARGET_USER" -printf '%u:%g %m %s %p\n' 2>/dev/null | head -n "$LINES" || \
  find "$TARGET_DIR" -xdev -maxdepth "$MAX_DEPTH" -user "$TARGET_USER" -exec ls -ld {} + 2>/dev/null | head -n "$LINES" || true
