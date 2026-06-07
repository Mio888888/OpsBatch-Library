#!/usr/bin/env bash
set -euo pipefail

if command -v ss >/dev/null 2>&1; then
  ss -tuln
elif command -v netstat >/dev/null 2>&1; then
  netstat -tuln
else
  lsof -nP -iTCP -sTCP:LISTEN
fi
