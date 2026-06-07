#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "== default route =="
    ip route show default || true

    echo
    echo "== route table =="
    ip route show table main
  elif command -v route >/dev/null 2>&1; then
    route -n
  elif command -v netstat >/dev/null 2>&1; then
    netstat -rn
  else
    echo "No route inspection command found."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  echo "== default route =="
  route -n get default 2>/dev/null || true

  echo
  echo "== route table =="
  netstat -rn
else
  echo "No supported route inspection command found."
fi
