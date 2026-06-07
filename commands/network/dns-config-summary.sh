#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== /etc/resolv.conf =="
  if [ -r /etc/resolv.conf ]; then
    sed -n '1,120p' /etc/resolv.conf
  else
    echo "/etc/resolv.conf is not readable."
  fi

  if command -v resolvectl >/dev/null 2>&1; then
    echo
    echo "== resolvectl status =="
    resolvectl status 2>/dev/null || true
  elif command -v systemd-resolve >/dev/null 2>&1; then
    echo
    echo "== systemd-resolve status =="
    systemd-resolve --status 2>/dev/null || true
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v scutil >/dev/null 2>&1; then
    echo "== DNS configuration =="
    scutil --dns
  else
    echo "scutil not available."
  fi
else
  echo "No supported DNS configuration command found."
fi
