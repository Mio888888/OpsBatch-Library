#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "== interfaces (brief) =="
    ip -brief address

    echo
    echo "== link state =="
    ip -brief link
  elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a
  else
    echo "Neither ip nor ifconfig is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v ifconfig >/dev/null 2>&1; then
    echo "== active interface addresses =="
    ifconfig -a
  else
    echo "ifconfig not available."
  fi

  if command -v networksetup >/dev/null 2>&1; then
    echo
    echo "== network services =="
    networksetup -listallhardwareports 2>/dev/null || true
  fi
else
  echo "No supported network interface command found."
fi
