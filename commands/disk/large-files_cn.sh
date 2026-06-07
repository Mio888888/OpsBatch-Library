#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-.}"
MIN_SIZE="${MIN_SIZE:-500M}"

echo "信息：== large files under $TARGET_DIR larger than $MIN_SIZE =="
if [ -d "$TARGET_DIR" ]; then
  find "$TARGET_DIR" -xdev -type f -size +"$MIN_SIZE" -print0 2>/dev/null \
    | xargs -0 ls -lh 2>/dev/null \
    | sort -k5 -hr \
    | head -50
else
  echo "信息：TARGET_DIR is not a directory: $TARGET_DIR"
  echo "信息：Usage: TARGET_DIR=/var MIN_SIZE=1G sh -c '<this command>'"
fi
