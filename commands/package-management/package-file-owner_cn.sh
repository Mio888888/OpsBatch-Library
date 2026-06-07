#!/usr/bin/env bash
set -euo pipefail

TARGET_FILE="${TARGET_FILE:-}"

if [ -z "$TARGET_FILE" ]; then
  echo "请将 TARGET_FILE 设置为绝对文件路径，例如 TARGET_FILE=/usr/bin/ssh。"
  exit 0
fi

echo "信息：== 软件包归属： $TARGET_FILE =="
if [ ! -e "$TARGET_FILE" ]; then
  echo "信息：File does not exist locally: $TARGET_FILE"
fi

if command -v dpkg-query >/dev/null 2>&1; then
  dpkg-query -S "$TARGET_FILE" 2>/dev/null || true
fi
if command -v rpm >/dev/null 2>&1; then
  rpm -qf "$TARGET_FILE" 2>/dev/null || true
fi
if command -v pacman >/dev/null 2>&1; then
  pacman -Qo "$TARGET_FILE" 2>/dev/null || true
fi
if command -v apk >/dev/null 2>&1; then
  apk info --who-owns "$TARGET_FILE" 2>/dev/null || true
fi
if command -v brew >/dev/null 2>&1; then
  brew list --formula 2>/dev/null | while read -r pkg; do
    brew list "$pkg" 2>/dev/null | grep -F -x "$TARGET_FILE" >/dev/null 2>&1 && echo "信息：brew formula: $pkg"
  done
fi
