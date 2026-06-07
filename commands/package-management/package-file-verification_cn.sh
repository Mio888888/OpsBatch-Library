#!/usr/bin/env bash
set -euo pipefail

TARGET_PACKAGE="${TARGET_PACKAGE:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "请设置 TARGET_PACKAGE to verify installed package files, for example TARGET_PACKAGE=openssh-client.（Set TARGET_PACKAGE to verify installed package files, for example TARGET_PACKAGE=openssh-client.）"
  echo "信息：This can be noisy and may reveal local file modification state."
  exit 0
fi

echo "信息：== package file verification: $TARGET_PACKAGE =="
if command -v dpkg >/dev/null 2>&1; then
  dpkg -V "$TARGET_PACKAGE" 2>/dev/null || true
fi
if command -v rpm >/dev/null 2>&1; then
  rpm -V "$TARGET_PACKAGE" 2>/dev/null || true
fi
if command -v pacman >/dev/null 2>&1; then
  pacman -Qkk "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true
fi
if command -v apk >/dev/null 2>&1; then
  apk audit 2>/dev/null | grep -F "$TARGET_PACKAGE" | sed -n '1,80p' || true
fi
if command -v brew >/dev/null 2>&1; then
  brew linkage "$TARGET_PACKAGE" 2>/dev/null | sed -n '1,80p' || true
fi
