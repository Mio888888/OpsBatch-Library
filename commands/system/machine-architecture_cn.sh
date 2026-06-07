#!/usr/bin/env bash
set -euo pipefail

echo "信息：Machine: $(uname -m)"
echo "信息：Processor: $(uname -p 2>/dev/null || echo 未知)"
echo "信息：Hardware 平台： $(uname -i 2>/dev/null || echo 未知)"
if command -v arch >/dev/null 2>&1; then
  echo "信息：arch: $(arch)"
fi
