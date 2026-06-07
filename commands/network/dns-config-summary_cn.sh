#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "信息：== /etc/resolv.conf =="
  if [ -r /etc/resolv.conf ]; then
    sed -n '1,120p' /etc/resolv.conf
  else
    echo "信息：/etc/resolv.conf is not readable."
  fi

  if command -v resolvectl >/dev/null 2>&1; then
    echo
    echo "信息：== resolvectl status =="
    resolvectl status 2>/dev/null || true
  elif command -v systemd-resolve >/dev/null 2>&1; then
    echo
    echo "信息：== systemd-resolve status =="
    systemd-resolve --status 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v scutil >/dev/null 2>&1; then
    echo "信息：== DNS configuration =="
    scutil --dns
  else
    echo "scutil 不可用.（scutil not available.）"
  fi
else
  echo "未找到受支持的 DNS configuration command found.（No supported DNS configuration command found.）"
fi
