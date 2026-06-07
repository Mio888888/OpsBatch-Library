#!/usr/bin/env bash
set -euo pipefail

echo "Hostname: $(hostname 2>/dev/null || echo unknown)"
echo "Kernel: $(uname -a)"
if [ -f /etc/os-release ]; then
  echo "OS Release:"
  sed -n 's/^PRETTY_NAME=/PRETTY_NAME=/p; s/^ID=/ID=/p; s/^VERSION_ID=/VERSION_ID=/p' /etc/os-release
elif command -v sw_vers >/dev/null 2>&1; then
  sw_vers
else
  echo "No supported OS release metadata found."
fi
