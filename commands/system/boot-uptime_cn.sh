#!/usr/bin/env bash
set -euo pipefail

echo "信息：Uptime:"
uptime
echo "信息：Boot time:"
if command -v who >/dev/null 2>&1; then
  who -b 2>/dev/null || true
fi
if command -v sysctl >/dev/null 2>&1; then
  sysctl kern.boottime 2>/dev/null || true
fi
