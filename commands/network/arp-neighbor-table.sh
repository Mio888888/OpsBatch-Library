#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "== neighbor table =="
    ip neigh show
  elif command -v arp >/dev/null 2>&1; then
    arp -an
  else
    echo "Neither ip nor arp is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v arp >/dev/null 2>&1; then
    echo "== ARP table =="
    arp -an
  else
    echo "arp not available."
  fi
else
  echo "No supported ARP/neighbor command found."
fi
