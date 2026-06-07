#!/usr/bin/env bash
set -euo pipefail

echo "信息：Hostname: $(hostname 2>/dev/null || echo unknown)"
echo "信息：Kernel: $(uname -a)"
if [ -f /etc/os-release ]; then
  echo "信息：OS Release:"
  sed -n 's/^PRETTY_NAME=/PRETTY_NAME=/p; s/^ID=/ID=/p; s/^VERSION_ID=/VERSION_ID=/p' /etc/os-release
elif command -v sw_vers >/dev/null 2>&1; then
  sw_vers
else
  echo "未找到受支持的 OS release metadata found.（No supported OS release metadata found.）"
fi
