#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "Set TARGET_DEVICE before running, for example TARGET_DEVICE=/dev/sdb."
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v badblocks >/dev/null 2>&1; then
    echo "Running read-only badblocks scan. This can take a long time and should be scheduled carefully."
    sudo badblocks -sv "$TARGET_DEVICE"
  else
    echo "badblocks not installed."
  fi
else
  echo "badblocks scan is Linux-specific in this command."
fi
