#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Linux" ]; then
  echo "== process network namespaces =="
  if command -v lsns >/dev/null 2>&1; then
    lsns -t net
  else
    echo "lsns not installed; showing namespace symlinks for first processes."
    find /proc/[0-9]*/ns/net -maxdepth 0 -type l -print 2>/dev/null | head -40 | while read -r ns; do
      printf '%s -> ' "$ns"
      readlink "$ns" 2>/dev/null || true
    done
  fi

  if command -v ip >/dev/null 2>&1; then
    echo
    echo "== named network namespaces =="
    ip netns list 2>/dev/null || true
  fi
else
  echo "Network namespaces are Linux-specific; no macOS equivalent is shown."
fi
