#!/usr/bin/env bash
set -euo pipefail

LIMIT="${LIMIT:-80}"
echo "信息：== language ecosystem package inventory (limit: $LIMIT) =="

if command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1; then
  PIP_BIN="$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null)"
  echo "信息：-- pip packages --"
  "$PIP_BIN" list 2>/dev/null | sed -n '1,80p' || true
  echo "信息：-- pip outdated check note --"
  echo "信息：Not running pip list --outdated because it may query package indexes."
else
  echo "pip 未找到（pip not found）"
fi

if command -v npm >/dev/null 2>&1; then
  echo "信息：-- npm global packages --"
  npm list -g --depth=0 2>/dev/null | sed -n '1,80p' || true
  echo "信息：-- npm project packages --"
  if [ -r package.json ]; then
    npm list --depth=0 2>/dev/null | sed -n '1,80p' || true
  else
    echo "信息：No package.json in current directory; skipping project package list."
  fi
else
  echo "npm 未找到（npm not found）"
fi
