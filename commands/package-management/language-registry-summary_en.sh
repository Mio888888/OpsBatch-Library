#!/usr/bin/env bash
set -euo pipefail

echo "== language package manager registry/config summary =="

if command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1; then
  PIP_BIN="$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null)"
  echo "-- pip --"
  "$PIP_BIN" --version 2>/dev/null || true
  "$PIP_BIN" config list 2>/dev/null | sed -E 's#(password|token|secret|key)[^=]*=.*#\1=***redacted***#Ig' || true
else
  echo "pip not found"
fi

if command -v npm >/dev/null 2>&1; then
  echo "-- npm --"
  npm --version 2>/dev/null || true
  npm config get registry 2>/dev/null | sed 's#.*#registry=& #' || true
  npm config list 2>/dev/null | grep -E '(^;|registry|prefix|cache|strict-ssl|proxy)' | sed -E 's#(_authToken|password|token|secret|key).*#\1=***redacted***#Ig' || true
else
  echo "npm not found"
fi
