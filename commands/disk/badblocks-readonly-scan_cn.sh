#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "请设置 TARGET_DEVICE before running, for example TARGET_DEVICE=/dev/sdb.（Set TARGET_DEVICE before running, for example TARGET_DEVICE=/dev/sdb.）"
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v badblocks >/dev/null 2>&1; then
    echo "信息：Running read-only badblocks scan. This can take a long time and should be scheduled carefully."
    sudo badblocks -sv "$TARGET_DEVICE"
  else
    echo "信息：badblocks not installed."
  fi
else
  echo "信息：badblocks scan is Linux-specific in this command."
fi
