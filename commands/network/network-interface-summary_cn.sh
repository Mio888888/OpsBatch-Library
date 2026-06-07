#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v ip >/dev/null 2>&1; then
    echo "信息：== interfaces (brief) =="
    ip -brief address

    echo
    echo "信息：== link state =="
    ip -brief link
  elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a
  else
    echo "信息：Neither ip nor ifconfig is installed."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  if command -v ifconfig >/dev/null 2>&1; then
    echo "信息：== active interface addresses =="
    ifconfig -a
  else
    echo "ifconfig 不可用.（ifconfig not available.）"
  fi

  if command -v networksetup >/dev/null 2>&1; then
    echo
    echo "信息：== network services =="
    networksetup -listallhardwareports 2>/dev/null || true
  fi
else
  echo "未找到受支持的 network interface command found.（No supported network interface command found.）"
fi
