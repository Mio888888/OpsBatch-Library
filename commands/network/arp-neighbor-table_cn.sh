#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "信息：== neighbor table =="
    ip neigh show
  elif command -v arp >/dev/null 2>&1; then
    arp -an
  else
    echo "信息：Neither ip nor arp is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v arp >/dev/null 2>&1; then
    echo "信息：== ARP table =="
    arp -an
  else
    echo "arp 不可用.（arp not available.）"
  fi
else
  echo "未找到受支持的 ARP/neighbor command found.（No supported ARP/neighbor command found.）"
fi
