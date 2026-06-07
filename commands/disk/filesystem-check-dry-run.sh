#!/usr/bin/env bash
set -euo pipefail

TARGET_DEVICE="${TARGET_DEVICE:-}"
if [ -z "$TARGET_DEVICE" ]; then
  echo "Set TARGET_DEVICE before running, for example TARGET_DEVICE=/dev/sdb1."
  exit 0
fi

if [ "$(uname -s)" = "Linux" ]; then
  if command -v fsck >/dev/null 2>&1; then
    echo "Running fsck in no-write mode where supported. Device should be unmounted for reliable results."
    sudo fsck -N "$TARGET_DEVICE" 2>/dev/null || fsck -N "$TARGET_DEVICE" 2>/dev/null || true
    sudo fsck -n "$TARGET_DEVICE" 2>/dev/null || fsck -n "$TARGET_DEVICE" 2>/dev/null || true
  else
    echo "fsck not installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  diskutil verifyVolume "$TARGET_DEVICE" 2>/dev/null || true
else
  echo "No supported filesystem check command found."
fi
