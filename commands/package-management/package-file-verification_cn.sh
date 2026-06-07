#!/usr/bin/env bash
set -euo pipefail

TARGET_PACKAGE="${TARGET_PACKAGE:-}"

if [ -z "$TARGET_PACKAGE" ]; then
  echo "请设置 TARGET_PACKAGE 以验证已安装软件包文件，例如 TARGET_PACKAGE=openssh-client。"
  echo "信息：这可能输出较多内容，并可能暴露本地文件修改状态。"
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
