#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-80}"
echo "== language ecosystem package inventory (limit: $LIMIT) =="

if command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1; then
  PIP_BIN="$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null)"
  echo "-- pip packages --"
  "$PIP_BIN" list 2>/dev/null | sed -n '1,80p' || true
  echo "-- pip outdated check note --"
  echo "Not running pip list --outdated because it may query package indexes."
else
  echo "pip not found"
fi

if command -v npm >/dev/null 2>&1; then
  echo "-- npm global packages --"
  npm list -g --depth=0 2>/dev/null | sed -n '1,80p' || true
  echo "-- npm project packages --"
  if [ -r package.json ]; then
    npm list --depth=0 2>/dev/null | sed -n '1,80p' || true
  else
    echo "No package.json in current directory; skipping project package list."
  fi
else
  echo "npm not found"
fi
