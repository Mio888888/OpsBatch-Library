#!/usr/bin/env bash
set -euo pipefail

echo "Machine: $(uname -m)"
echo "Processor: $(uname -p 2>/dev/null || echo unknown)"
echo "Hardware platform: $(uname -i 2>/dev/null || echo unknown)"
if command -v arch >/dev/null 2>&1; then
  echo "arch: $(arch)"
fi
