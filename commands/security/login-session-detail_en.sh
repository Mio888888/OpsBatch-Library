#!/usr/bin/env bash
set -euo pipefail

echo "== who =="
who 2>/dev/null || true

echo
echo "== w =="
w 2>/dev/null || true

if [ "$(uname -s)" = "Linux" ] && command -v loginctl >/dev/null 2>&1; then
  echo
  echo "== loginctl sessions =="
  loginctl list-sessions 2>/dev/null || true
fi

echo
echo "== recent logins =="
last -n "${LINES:-20}" 2>/dev/null || echo "Recent login history unavailable."
