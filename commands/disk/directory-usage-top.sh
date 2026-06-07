#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-.}"
DEPTH="${DEPTH:-1}"

echo "== top directory usage: $TARGET_DIR (depth=$DEPTH) =="
if [ -d "$TARGET_DIR" ]; then
  du -xh -d "$DEPTH" "$TARGET_DIR" 2>/dev/null | sort -hr | head -30
else
  echo "TARGET_DIR is not a directory: $TARGET_DIR"
  echo "Usage: TARGET_DIR=/var DEPTH=1 sh -c '<this command>'"
fi
