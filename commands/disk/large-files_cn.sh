#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-.}"
MIN_SIZE="${MIN_SIZE:-500M}"

echo "信息：== 大文件目录： $TARGET_DIR 大于 $MIN_SIZE =="
if [ -d "$TARGET_DIR" ]; then
  find "$TARGET_DIR" -xdev -type f -size +"$MIN_SIZE" -print0 2>/dev/null \
    | xargs -0 ls -lh 2>/dev/null \
    | sort -k5 -hr \
    | head -50
else
  echo "信息：TARGET_DIR 不是目录: $TARGET_DIR"
  echo "信息：用法： TARGET_DIR=/var MIN_SIZE=1G sh -c '<this command>'"
fi
