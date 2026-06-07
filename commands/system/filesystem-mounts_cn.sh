#!/usr/bin/env bash
set -euo pipefail

echo "信息：Mounted filesystems:"
if command -v findmnt >/dev/null 2>&1; then
  findmnt -D
else
  mount | head -50
fi
echo "信息：Disk usage summary:"
df -h
