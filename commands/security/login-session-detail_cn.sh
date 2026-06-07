#!/usr/bin/env bash
set -euo pipefail

echo "信息：== who =="
who 2>/dev/null || true

echo
echo "信息：== w =="
w 2>/dev/null || true

if [ "$(uname -s)" = "Linux" ] && command -v loginctl >/dev/null 2>&1; then
  echo
  echo "信息：== loginctl sessions =="
  loginctl list-sessions 2>/dev/null || true
fi

echo
echo "信息：== recent logins =="
last -n "${LINES:-20}" 2>/dev/null || echo "信息：Recent login history unavailable."
