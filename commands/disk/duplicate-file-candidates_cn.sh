#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-.}"
MIN_SIZE="${MIN_SIZE:-10M}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "信息：TARGET_DIR 不是目录: $TARGET_DIR"
  exit 0
fi

if command -v shasum >/dev/null 2>&1; then
  HASH_CMD="shasum -a 256"
elif command -v sha256sum >/dev/null 2>&1; then
  HASH_CMD="sha256sum"
else
  echo "信息：未找到 sha256 哈希命令。"
  exit 0
fi

echo "信息：== 重复文件候选项目录： $TARGET_DIR 大于 $MIN_SIZE =="
find "$TARGET_DIR" -xdev -type f -size +"$MIN_SIZE" -print0 2>/dev/null \
  | xargs -0 $HASH_CMD 2>/dev/null \
  | sort \
  | awk 'seen[$1]++ || count[$1] {print}' \
  | head -100
