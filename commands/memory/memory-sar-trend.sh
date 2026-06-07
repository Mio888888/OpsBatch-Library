#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v sar >/dev/null 2>&1; then
    echo "== sar -r recent memory trend =="
    sar -r 1 3

    echo
    echo "== sar -S recent swap trend =="
    sar -S 1 3 2>/dev/null || echo "sar -S is not available in this sysstat version."
  else
    echo "sar command not installed; install sysstat to view historical memory trends."
    if command -v free >/dev/null 2>&1; then
      echo
      echo "Fallback current memory snapshot:"
      free -h
    fi
  fi
else
  echo "sar memory trend inspection in this command is Linux/sysstat specific."
fi
