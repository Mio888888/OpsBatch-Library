#!/usr/bin/env bash
set -euo pipefail

echo "信息：Machine: $(uname -m)"
echo "信息：Processor: $(uname -p 2>/dev/null || echo unknown)"
echo "信息：Hardware platform: $(uname -i 2>/dev/null || echo unknown)"
if command -v arch >/dev/null 2>&1; then
  echo "信息：arch: $(arch)"
fi
