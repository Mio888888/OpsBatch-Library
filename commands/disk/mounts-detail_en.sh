#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  if command -v findmnt >/dev/null 2>&1; then
    findmnt -A -o TARGET,SOURCE,FSTYPE,OPTIONS
  else
    mount | sort
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  mount | sort
else
  echo "No supported mount inspection command found."
fi
