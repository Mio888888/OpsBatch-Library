#!/usr/bin/env bash
set -euo pipefail

if command -v lsof >/dev/null 2>&1; then
  echo "信息：== deleted files still held open =="
  sudo lsof +L1 2>/dev/null || lsof +L1 2>/dev/null || true
elif [ "$(uname -s)" = "Linux" ]; then
  echo "信息：lsof not installed; fallback scanning /proc file descriptors."
  find /proc/*/fd -lname '* (deleted)' -print 2>/dev/null | head -100
else
  echo "信息：lsof is required on this platform."
fi
