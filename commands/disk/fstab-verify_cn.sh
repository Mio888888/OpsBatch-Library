#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== /etc/fstab entries =="
  grep -Ev '^\s*(#|$)' /etc/fstab 2>/dev/null || true

  echo
  echo "信息：== findmnt verify =="
  if command -v findmnt >/dev/null 2>&1; then
    findmnt --verify --verbose 2>/dev/null || true
  else
    echo "信息：findmnt not installed; cannot verify fstab."
  fi
else
  echo "信息：fstab verification is Linux-specific in this command. macOS uses different mount configuration mechanisms."
fi
